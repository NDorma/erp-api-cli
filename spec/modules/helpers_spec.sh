Describe "Test helper functions"
  ERP_API_CLI_ENVIRONMENT="testing"
  ERP_API_CLI_TOKEN="token"
  
  Include ./modules/variables.sh
  Include ./modules/helpers.sh 
  Include ./modules/ui.sh
  Include ./modules/cache.sh

  Describe "Test invoke_subcommand function"

    It "returns error message with exit code 16 when no given sub-command"
      When call invoke_subcommand
      # Dump
      The status should be failure
      The output should include "Error code [16]"
    End

    It "returns error message with exit code 17 when no variable ERP_API_CLI_ENVIRONMENT defined"
      unset ERP_API_CLI_ENVIRONMENT
      When call invoke_subcommand
      # Dump
      The status should be failure
      The output should include "Error code [17]"
    End

    It "returns error message with exit code 18 when no variable ERP_API_CLI_TOKEN defined"
      unset ERP_API_CLI_TOKEN
      When call invoke_subcommand
      # Dump
      The status should be failure
      The output should include "Error code [18]"
    End

    It "returns error message with non-zero exit code when given sub-command does not exists"
      When call invoke_subcommand unexistent-subcommand
      # Dump
      The status should be failure
      The output should include ""
      The stderr should include "unexistent-subcommand_: command not found"
    End

    It "success message when given ui cache-flush sub-command"
      When call invoke_subcommand "ui" "cache-flush"
      The status should be success
    End
  End

  Describe "Test do_hash function"
    Include ./modules/credentials.sh
    It "returns the sha256 checksum of string"
      When call do_hash "claca"
      The output should eq "15e8a7d6bd9a1951aa08fd4a91ac18db4bff9d2d7db686504d11e8d59b89ab9d"
    End
  End

  Describe "Test print_cli_error_message function"
    It "returns error message of given code and status failure"
      When call print_cli_error_message 33
      The status should be failure
      The stdout should include "Error code [33]"
    End

    It "returns no output and status success when code 0 is given"
      When call print_cli_error_message 0
      The status should be success
    End
  End

  Describe "Test check_response_error function"
    It "returns failure if response contains error: true"
      When call check_response_error "{\"error\": true}"
      The status should be failure
      The stderr should eq ""
      The stdout should eq ""
    End
    
    It "returns success if response contains error: false"
      When call check_response_error "{\"error\": false}"
      The status should be success
      The stderr should eq ""
      The stdout should eq ""
    End
  End

  Describe "Test print_response_errors function"
    It "returns errors of response"
      When call print_response_errors "{\"errors\": [\"Error 1\", \"Error 2\"]}"
      The line 1 of stdout should eq "Error 1"
      The line 2 of stdout should eq "Error 2"
    End
  End

  Describe "Test print_response_messages function"
    It "returns messages of response"
      When call print_response_messages "{\"messages\": [\"Message 1\", \"Message 2\"]}"
      The line 1 of stdout should eq "Message 1"
      The line 2 of stdout should eq "Message 2"
    End
  End

  Describe "Test print_response_data function"
    It "returns pretty printed data of response"
      When call print_response_data "{\"data\": {\"key1\": \"Value 1\"}}"
      The stdout should include "\"key1\": \"Value 1\""
    End
  End
End
