package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/packer"
)

// Use Packer to build the AMI in the given packer template, with the given build name, and return the AMI's ID
func buildAmi(t *testing.T, packerTemplatePath string, packerBuildName string, awsRegion string, downloadUrl string) string {
	options := &packer.Options{
		Template: packerTemplatePath,
		Only:     packerBuildName,
		Vars: map[string]string{
			"aws_region": awsRegion,
		},
	}

	return packer.BuildAmi(t, options)
}
