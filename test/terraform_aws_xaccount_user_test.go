// =================================================================
//
// Work of the U.S. Department of Defense, Defense Digital Service.
// Released as open source under the MIT License.  See LICENSE file.
//
// =================================================================

package test

import (
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformXAccountUserExample(t *testing.T) {
	t.Parallel()

	region := os.Getenv("AWS_DEFAULT_REGION")
	if len(region) == 0 {
		t.Fatal("missing environment variable AWS_DEFAULT_REGION")
	}

	user_arn := os.Getenv("XACCOUNT_USER_ARN")
	if len(user_arn) == 0 {
		t.Fatal("missing environment variable XACCOUNT_USER_ARN")
	}

	testName := fmt.Sprintf("terratest-sqs-queue-xaccount-user-%s", strings.ToLower(random.UniqueId()))

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/xaccount_user",
		Vars: map[string]interface{}{
			"user_arn":  user_arn,
			"test_name": testName,
			"tags": map[string]interface{}{
				"Automation": "Terraform",
				"Terratest":  "yes",
				"Test":       "TestTerraformXAccountUserExample",
			},
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": region,
		},
	})
	if os.Getenv("SKIP_TF_DESTROY") != "1" {
		defer terraform.Destroy(t, terraformOptions)
	}

	terraform.InitAndApply(t, terraformOptions)
}
