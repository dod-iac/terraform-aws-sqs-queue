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

func TestTerraformXAccountExample(t *testing.T) {
	t.Parallel()

	region := os.Getenv("AWS_DEFAULT_REGION")
	if len(region) == 0 {
		t.Fatal("missing environment variable AWS_DEFAULT_REGION")
	}

	account_id := os.Getenv("XACCOUNT_ACCOUNT_ID")
	if len(account_id) == 0 {
		t.Fatal("missing environment variable XACCOUNT_ACCOUNT_ID")
	}

	testName := fmt.Sprintf("terratest-sqs-queue-xaccount-%s", strings.ToLower(random.UniqueId()))

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/xaccount",
		Vars: map[string]interface{}{
			"account_id": account_id,
			"test_name":  testName,
			"tags": map[string]interface{}{
				"Automation": "Terraform",
				"Terratest":  "yes",
				"Test":       "TestTerraformXAccountExample",
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
