source ./modules/helpers.sh 

Describe "Test helper functions"

  Describe "Test do_hash function"
    It "returns the sha256 checksum of string"
      When call do_hash "claca"
      The output should eq "15e8a7d6bd9a1951aa08fd4a91ac18db4bff9d2d7db686504d11e8d59b89ab9d"
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
