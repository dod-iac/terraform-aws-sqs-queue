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
	"github.com/stretchr/testify/require"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformCrossAccountExample(t *testing.T) {
	t.Parallel()

	region := os.Getenv("AWS_DEFAULT_REGION")
	require.NotEmpty(t, region, "missing environment variable AWS_DEFAULT_REGION")

	accountID := os.Getenv("TT_ACCOUNT_ID")
	require.NotEmpty(t, region, "missing environment variable TT_ACCOUNT_ID")

	testName := fmt.Sprintf("terratest-sqs-queue-cross-account-%s", strings.ToLower(random.UniqueId()))

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/cross_account",
		Vars: map[string]interface{}{
			"account_id": accountID,
			"test_name":  testName,
			"tags": map[string]interface{}{
				"Automation": "Terraform",
				"Terratest":  "yes",
				"Test":       "TestTerraformCrossAccountExample",
			},
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": region,
		},
	})
	if os.Getenv("TT_SKIP_DESTROY") != "1" {
		defer terraform.Destroy(t, terraformOptions)
	}
	terraform.InitAndApply(t, terraformOptions)
}
