package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/packer"
	"github.com/gruntwork-io/terratest/modules/test-structure"
)

// Build the AMI in ecs-ami module
func buildEcsAMI(t *testing.T, awsRegion string, workingDir string) {
	packerOptions := &packer.Options{
		// The path to where the Packer template is located
		Template: "../modules/app-cluster/aws/ecs-ami/ecs.json",

		// Only build the AMI
		Only: "ubuntu-ami",

		// Variables to pass to our Packer build using -var options
		Vars: map[string]string{
			"aws_region": awsRegion,
		},
	}

	// Save the Packer Options so future test stages can use them
	test_structure.SavePackerOptions(t, workingDir, packerOptions)

	// Build the AMI
	amiID := packer.BuildAmi(t, packerOptions)

	// Save the AMI ID so future test stages can use them
	test_structure.SaveAmiId(t, workingDir, amiID)
}

func buildJenkinsAMI(t *testing.T, awsRegion string, workingDir string) {
	// TODO - implement
}

// Delete the AMI
func deleteAMI(t *testing.T, awsRegion string, workingDir string) {
	// Load the AMI ID and Packer Options saved by the earlier build_ami stage
	amiID := test_structure.LoadAmiId(t, workingDir)

	aws.DeleteAmi(t, awsRegion, amiID)
}
