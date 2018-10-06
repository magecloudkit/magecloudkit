package test

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestBastionSsh(t *testing.T) {
	t.Parallel()

	//os.Setenv("SKIP_build_ami", "true")
	os.Setenv("SKIP_cleanup_ami", "true")

	workingDir := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/magecloudkit-simple-vpc")

	// At the end of the test, delete the AMI
	defer test_structure.RunTestStage(t, "cleanup_ami", func() {
		awsRegion := test_structure.LoadString(t, workingDir, "awsRegion")
		deleteAMI(t, awsRegion, workingDir)
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer test_structure.RunTestStage(t, "teardown", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
		terraform.Destroy(t, terraformOptions)

		keyPair := test_structure.LoadEc2KeyPair(t, workingDir)
		aws.DeleteEC2KeyPair(t, keyPair)
	})

	// Build the AMI for the ECS app
	test_structure.RunTestStage(t, "build_ami", func() {
		// Pick a random AWS region to test in. This helps ensure your code works in all regions.
		// Note: that we limit this only to regions where EFS is supported.
		approvedRegions := []string{"us-east-1", "us-east-2", "us-west-1", "us-west-2", "eu-central-1", "eu-west-1", "ap-northeast-1", "ap-northeast-2", "ap-southeast-1", "ap-southeast-2"}
		awsRegion := aws.GetRandomRegion(t, approvedRegions, nil)
		test_structure.SaveString(t, workingDir, "awsRegion", awsRegion)
		buildEcsAMI(t, awsRegion, workingDir)
	})

	// Deploy the example
	test_structure.RunTestStage(t, "setup", func() {
		terraformOptions, keyPair := configureTerraformOptions(t, workingDir)

		// Save the options and key pair so later test stages can use them
		test_structure.SaveTerraformOptions(t, workingDir, terraformOptions)
		test_structure.SaveEc2KeyPair(t, workingDir, keyPair)

		// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
		terraform.InitAndApply(t, terraformOptions)
	})

	// Make sure we can SSH to the Bastion instance directly from the public Internet and then a private ECS cluster instance
	// by using the Bastion instance as a jump host.
	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
		keyPair := test_structure.LoadEc2KeyPair(t, workingDir)

		testSSHToPublicHost(t, terraformOptions, keyPair)
		//testSSHToPrivateHost(t, terraformOptions, keyPair)
		testSSHAgentToPublicHost(t, terraformOptions, keyPair)
		//testSSHAgentToPrivateHost(t, terraformOptions, keyPair)
		testSCPToPublicHost(t, terraformOptions, keyPair)
	})
}

func configureTerraformOptions(t *testing.T, workingDir string) (*terraform.Options, *aws.Ec2Keypair) {
	// A unique ID we can use to namespace resources so we don't clash with anything already in the AWS account or
	// tests running in parallel
	uniqueID := random.UniqueId()

	// Give this EC2 Instance and other resources in the Terraform code a name with a unique ID so it doesn't clash
	// with anything else in the AWS account.
	//instanceName := fmt.Sprintf("terratest-ssh-example-%s", uniqueID)

	// Get the AWS region
	awsRegion := test_structure.LoadString(t, workingDir, "awsRegion")

	// Get the availability zones for the given region
	azs := aws.GetAvailabilityZones(t, awsRegion)

	// Create an EC2 KeyPair that we can use for SSH access
	keyPairName := fmt.Sprintf("terratest-ssh-example-%s", uniqueID)
	keyPair := aws.CreateAndImportEC2KeyPair(t, awsRegion, keyPairName)

	// Load the AMI ID and Packer Options saved by the earlier build_ami stage
	amiID := test_structure.LoadAmiId(t, workingDir)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: workingDir,

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"aws_region":         awsRegion,
			"availability_zones": azs,
			"ecs_ami":            amiID,
			"key_pair_name":      keyPairName,
		},
	}

	return terraformOptions, keyPair
}

func testScpDirFromHost(t *testing.T, terraformOptions *terraform.Options, keyPair *aws.Ec2Keypair) {
	// Run `terraform output` to get the value of an output variable
	publicInstanceIP := terraform.Output(t, terraformOptions, "bastion_ip")

	// We're going to try to SSH to the instance IP, using the Key Pair we created earlier, and the user "ubuntu",
	// as we know the Instance is running an Ubuntu AMI that has such a user
	publicHost := ssh.Host{
		Hostname:    publicInstanceIP,
		SshKeyPair:  keyPair.KeyPair,
		SshUserName: "ubuntu",
	}

	// It can take a minute or so for the Instance to boot up, so retry a few times
	maxRetries := 30
	timeBetweenRetries := 5 * time.Second
	description := fmt.Sprintf("SSH to public host %s", publicInstanceIP)
	remoteTempFolder := "/tmp/testFolder"
	remoteTempFilePath := filepath.Join(remoteTempFolder, "test.foo")
	remoteTempFilePath2 := filepath.Join(remoteTempFolder, "test.baz")
	randomData := random.UniqueId()

	// Verify that we can SSH to the Instance and run commands
	retry.DoWithRetry(t, description, maxRetries, timeBetweenRetries, func() (string, error) {
		_, err := ssh.CheckSshCommandE(t, publicHost, fmt.Sprintf("mkdir -p %s && touch %s && touch %s && echo \"%s\" >> %s", remoteTempFolder, remoteTempFilePath, remoteTempFilePath2, randomData, remoteTempFilePath))

		if err != nil {
			return "", err
		}

		return "", nil
	})

	// clean up the remote folder as we want may want to run another test case
	defer retry.DoWithRetry(t, description, maxRetries, timeBetweenRetries, func() (string, error) {
		_, err := ssh.CheckSshCommandE(t,
			publicHost,
			fmt.Sprintf("rm -rf %s", remoteTempFolder))

		if err != nil {
			return "", err
		}

		return "", nil
	})

	localDestDir := "/tmp/tempFolder"

	var testcases = []struct {
		options       ssh.ScpDownloadOptions
		expectedFiles int
	}{
		{
			ssh.ScpDownloadOptions{RemoteHost: publicHost, RemoteDir: remoteTempFolder, LocalDir: localDestDir},
			2,
		},
		{
			ssh.ScpDownloadOptions{RemoteHost: publicHost, RemoteDir: remoteTempFolder, LocalDir: localDestDir, FileNameFilter: "*.baz"},
			1,
		},
	}

	for _, testCase := range testcases {
		err := ssh.ScpDirFromE(t, testCase.options)

		if err != nil {
			t.Fatalf("Error copying from remote: %s", err.Error())
		}

		expectedNumFiles := testCase.expectedFiles

		fileInfos, err := ioutil.ReadDir(localDestDir)

		if err != nil {
			t.Fatalf("Error reading from local dir: %s, due to: %s", localDestDir, err.Error())
		}

		actualNumFilesCopied := len(fileInfos)

		if len(fileInfos) != expectedNumFiles {
			t.Fatalf("Error: expected %d files to be copied. Only found %d", expectedNumFiles, actualNumFilesCopied)
		}

		// Clean up the temp file we created
		os.RemoveAll(localDestDir)
	}
}

func testScpFromHost(t *testing.T, terraformOptions *terraform.Options, keyPair *aws.Ec2Keypair) {
	// Run `terraform output` to get the value of an output variable
	publicInstanceIP := terraform.Output(t, terraformOptions, "bastion_ip")

	// We're going to try to SSH to the instance IP, using the Key Pair we created earlier, and the user "ubuntu",
	// as we know the Instance is running an Ubuntu AMI that has such a user
	publicHost := ssh.Host{
		Hostname:    publicInstanceIP,
		SshKeyPair:  keyPair.KeyPair,
		SshUserName: "ubuntu",
	}

	// It can take a minute or so for the Instance to boot up, so retry a few times
	maxRetries := 30
	timeBetweenRetries := 5 * time.Second
	description := fmt.Sprintf("SSH to public host %s", publicInstanceIP)
	remoteTempFolder := "/tmp/testFolder"
	remoteTempFilePath := filepath.Join(remoteTempFolder, "test.out")
	randomData := random.UniqueId()

	// Verify that we can SSH to the Instance and run commands
	retry.DoWithRetry(t, description, maxRetries, timeBetweenRetries, func() (string, error) {
		_, err := ssh.CheckSshCommandE(t,
			publicHost,
			fmt.Sprintf("mkdir -p %s && touch %s && echo \"%s\" >> %s && touch /tmp/testFolder/bar.baz", remoteTempFolder, remoteTempFilePath, randomData, remoteTempFilePath))

		if err != nil {
			return "", err
		}

		return "", nil
	})

	// clean up the remote folder as we want may want to run another test case
	defer retry.DoWithRetry(t, description, maxRetries, timeBetweenRetries, func() (string, error) {
		_, err := ssh.CheckSshCommandE(t,
			publicHost,
			fmt.Sprintf("rm -rf %s", remoteTempFolder))

		if err != nil {
			return "", err
		}

		return "", nil
	})

	localTempFileName := "/tmp/test.out"
	localFile, err := os.Create(localTempFileName)

	// Clean up the temp file we created
	defer os.Remove(localTempFileName)

	if err != nil {
		t.Fatalf("Error: creating local temp file: %s", err.Error())
	}

	ssh.ScpFileFromE(t, publicHost, remoteTempFilePath, localFile)

	buf, err := ioutil.ReadFile(localTempFileName)

	if err != nil {
		t.Fatalf("Error: Unable to read local file from disk: %s", err.Error())
	}

	localFileContents := string(buf)

	if !strings.Contains(localFileContents, randomData) {
		t.Fatalf("Error: unable to find %s in the local file. Local file's contents were: %s", randomData, localFileContents)
	}
}

func testSSHToPublicHost(t *testing.T, terraformOptions *terraform.Options, keyPair *aws.Ec2Keypair) {
	// Run `terraform output` to get the value of an output variable
	publicInstanceIP := terraform.Output(t, terraformOptions, "bastion_ip")

	// We're going to try to SSH to the instance IP, using the Key Pair we created earlier, and the user "ubuntu",
	// as we know the Instance is running an Ubuntu AMI that has such a user
	publicHost := ssh.Host{
		Hostname:    publicInstanceIP,
		SshKeyPair:  keyPair.KeyPair,
		SshUserName: "ubuntu",
	}

	// It can take a minute or so for the Instance to boot up, so retry a few times
	maxRetries := 30
	timeBetweenRetries := 5 * time.Second
	description := fmt.Sprintf("SSH to public host %s", publicInstanceIP)

	// Run a simple echo command on the server
	expectedText := "Hello, World"
	command := fmt.Sprintf("echo -n '%s'", expectedText)

	// Verify that we can SSH to the Instance and run commands
	retry.DoWithRetry(t, description, maxRetries, timeBetweenRetries, func() (string, error) {
		actualText, err := ssh.CheckSshCommandE(t, publicHost, command)

		if err != nil {
			return "", err
		}

		if strings.TrimSpace(actualText) != expectedText {
			return "", fmt.Errorf("Expected SSH command to return '%s' but got '%s'", expectedText, actualText)
		}

		return "", nil
	})
}

func testSSHToPrivateHost(t *testing.T, terraformOptions *terraform.Options, keyPair *aws.Ec2Keypair) {
	// Run `terraform output` to get the value of an output variable
	publicInstanceIP := terraform.Output(t, terraformOptions, "bastion_ip")
	privateInstanceIP := terraform.Output(t, terraformOptions, "private_instance_ip")

	// We're going to try to SSH to the private instance using the public instance as a jump host. For both instances,
	// we are using the Key Pair we created earlier, and the user "ubuntu", as we know the Instances are running an
	// Ubuntu AMI that has such a user
	publicHost := ssh.Host{
		Hostname:    publicInstanceIP,
		SshKeyPair:  keyPair.KeyPair,
		SshUserName: "ubuntu",
	}
	privateHost := ssh.Host{
		Hostname:    privateInstanceIP,
		SshKeyPair:  keyPair.KeyPair,
		SshUserName: "ubuntu",
	}

	// It can take a minute or so for the Instance to boot up, so retry a few times
	maxRetries := 30
	timeBetweenRetries := 5 * time.Second
	description := fmt.Sprintf("SSH to private host %s via public host %s", publicInstanceIP, privateInstanceIP)

	// Run a simple echo command on the server
	expectedText := "Hello, World"
	command := fmt.Sprintf("echo -n '%s'", expectedText)

	// Verify that we can SSH to the Instance and run commands
	retry.DoWithRetry(t, description, maxRetries, timeBetweenRetries, func() (string, error) {
		actualText, err := ssh.CheckPrivateSshConnectionE(t, publicHost, privateHost, command)

		if err != nil {
			return "", err
		}

		if strings.TrimSpace(actualText) != expectedText {
			return "", fmt.Errorf("Expected SSH command to return '%s' but got '%s'", expectedText, actualText)
		}

		return "", nil
	})
}

func testSCPToPublicHost(t *testing.T, terraformOptions *terraform.Options, keyPair *aws.Ec2Keypair) {
	// Run `terraform output` to get the value of an output variable
	publicInstanceIP := terraform.Output(t, terraformOptions, "bastion_ip")

	// We're going to try to SSH to the instance IP, using the Key Pair we created earlier, and the user "ubuntu",
	// as we know the Instance is running an Ubuntu AMI that has such a user
	publicHost := ssh.Host{
		Hostname:    publicInstanceIP,
		SshKeyPair:  keyPair.KeyPair,
		SshUserName: "ubuntu",
	}

	// It can take a minute or so for the Instance to boot up, so retry a few times
	maxRetries := 10
	timeBetweenRetries := 1 * time.Second
	description := fmt.Sprintf("SCP file to public host %s", publicInstanceIP)

	// Run a simple echo command on the server
	expectedText := "Hello, World"

	// Verify that we can SSH to the Instance and run commands
	retry.DoWithRetry(t, description, maxRetries, timeBetweenRetries, func() (string, error) {
		err := ssh.ScpFileToE(t, publicHost, os.FileMode(0644), "/tmp/test.txt", expectedText)
		if err != nil {
			return "", err
		}

		actualText, err := ssh.FetchContentsOfFileE(t, publicHost, false, "/tmp/test.txt")

		if err != nil {
			return "", err
		}

		if strings.TrimSpace(actualText) != expectedText {
			return "", fmt.Errorf("Expected SSH command to return '%s' but got '%s'", expectedText, actualText)
		}

		return "", nil
	})
}

func testSSHAgentToPublicHost(t *testing.T, terraformOptions *terraform.Options, keyPair *aws.Ec2Keypair) {
	// Run `terraform output` to get the value of an output variable
	publicInstanceIP := terraform.Output(t, terraformOptions, "bastion_ip")

	// start the ssh agent
	sshAgent := ssh.SshAgentWithKeyPair(t, keyPair.KeyPair)
	defer sshAgent.Stop()

	// We're going to try to SSH to the instance IP, using the Key Pair we created earlier. Instead of
	// directly using the SSH key in the SSH connection, we're going to rely on an existing SSH agent that we
	// programatically emulate within this test. We're going to use the user "ubuntu" as we know the Instance
	// is running an Ubuntu AMI that has such a user
	publicHost := ssh.Host{
		Hostname:         publicInstanceIP,
		SshUserName:      "ubuntu",
		OverrideSshAgent: sshAgent,
	}

	// It can take a minute or so for the Instance to boot up, so retry a few times
	maxRetries := 30
	timeBetweenRetries := 5 * time.Second
	description := fmt.Sprintf("SSH with Agent to public host %s", publicInstanceIP)

	// Run a simple echo command on the server
	expectedText := "Hello, World"
	command := fmt.Sprintf("echo -n '%s'", expectedText)

	// Verify that we can SSH to the Instance and run commands
	retry.DoWithRetry(t, description, maxRetries, timeBetweenRetries, func() (string, error) {

		actualText, err := ssh.CheckSshCommandE(t, publicHost, command)

		if err != nil {
			return "", err
		}

		if strings.TrimSpace(actualText) != expectedText {
			return "", fmt.Errorf("Expected SSH command to return '%s' but got '%s'", expectedText, actualText)
		}

		return "", nil
	})
}

func testSSHAgentToPrivateHost(t *testing.T, terraformOptions *terraform.Options, keyPair *aws.Ec2Keypair) {
	// Run `terraform output` to get the value of an output variable
	publicInstanceIP := terraform.Output(t, terraformOptions, "bastion_ip")
	privateInstanceIP := terraform.Output(t, terraformOptions, "private_instance_ip")

	// start the ssh agent
	sshAgent := ssh.SshAgentWithKeyPair(t, keyPair.KeyPair)
	defer sshAgent.Stop()

	// We're going to try to SSH to the private instance using the public instance as a jump host. Instead of
	// directly using the SSH key in the SSH connection, we're going to rely on an existing SSH agent that we
	// programatically emulate within this test. For both instances, we are using the Key Pair we created earlier,
	// and the user "ubuntu", as we know the Instances are running an Ubuntu AMI that has such a user
	publicHost := ssh.Host{
		Hostname:         publicInstanceIP,
		SshUserName:      "ubuntu",
		OverrideSshAgent: sshAgent,
	}
	privateHost := ssh.Host{
		Hostname:         privateInstanceIP,
		SshUserName:      "ubuntu",
		OverrideSshAgent: sshAgent,
	}

	// It can take a minute or so for the Instance to boot up, so retry a few times
	maxRetries := 30
	timeBetweenRetries := 5 * time.Second
	description := fmt.Sprintf("SSH with Agent to private host %s via public host %s", publicInstanceIP, privateInstanceIP)

	// Run a simple echo command on the server
	expectedText := "Hello, World"
	command := fmt.Sprintf("echo -n '%s'", expectedText)

	// Verify that we can SSH to the Instance and run commands
	retry.DoWithRetry(t, description, maxRetries, timeBetweenRetries, func() (string, error) {

		actualText, err := ssh.CheckPrivateSshConnectionE(t, publicHost, privateHost, command)

		if err != nil {
			return "", err
		}

		if strings.TrimSpace(actualText) != expectedText {
			return "", fmt.Errorf("Expected SSH command to return '%s' but got '%s'", expectedText, actualText)
		}

		return "", nil
	})
}
