*** Settings ***
Documentation   Testing that possible long error messages over a set limit are truncated
Suite Setup     Run Tests  --maxerrorlines 30  cli/console/max_error_lines.robot
Resource        atest_resource.robot

*** Variables ***
${EXPLANATION}  \n${SPACE*4}[ Message content over the limit has been removed. ]\n
${3DOTS}  \\.\\.\\.

*** Test Cases ***
Under The Limit
    Has Not Been Cut  50 x 1 Message Under The Limit
    Has Not Been Cut  100 x 1 Message Under The Limit
    Has Not Been Cut  50 x 10 Message Under The Limit
    Has Not Been Cut  150 X 19 Message Under The Limit

On The Limit
    Has Not Been Cut  20 x 30 Message On The Limit
    Has Not Been Cut  150 x 15 Message On The Limit
    Has Not Been Cut  2340 x 1 Message On The Limit

Over The Limit
    Has Been Cut  8 x 31 Message Over The Limit
    Has Been Cut  79 x 30 Message Over The Limit
    Has Been Cut  400 x 7 Message Over The Limit  801.*${3DOTS}  ${3DOTS}.*END
    Has Been Cut  2341 x 1 Message Over The Limit  .*${3DOTS}\\n  ${3DOTS}.*\\n

Multiple Short Errors
    ${tc} =  Has Been Cut  ${TESTNAME}
    Should Contain X Times  ${tc.message}  \n  30

Two long errors
    ${tc} =  Has Been Cut  ${TESTNAME}
    Should Contain X Times    ${tc.message}    \n    30
    Should Start With    ${tc.message}    Several failures occurred:\n\n1) ContinuableApocalypseException: 1
    Should End With    ${tc.message}    1961~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~2000

*** Keywords ***
Has Been Cut
    [Arguments]  ${test}  ${eol_dots}=  ${bol_dots}=
    ${test} =  Get Test Case  ${test}
    Should Contain  ${test.message}  ${EXPLANATION}
    Should Match Non Empty Regexp  ${test.message}  ${eol_dots}
    Should Match Non Empty Regexp  ${test.message}  ${bol_dots}
    Error Message In Log Should Not Have Been Cut  ${test.kws}
    [Return]  ${test}

Error Message In Log Should Not Have Been Cut
    [Arguments]  ${kws}
    @{keywords} =  Set Variable  ${kws}
    :FOR  ${kw}  IN  @{keywords}
    \  Run Keyword If  ${kw.msgs}
    ...  Should Not Contain  ${kw.msgs[-1].message}  ${EXPLANATION}
    \  Error Message In Log Should Not Have Been Cut  ${kw.kws}

Should Match Non Empty Regexp
    [Arguments]  ${message}  ${pattern}
    Run Keyword If  '${pattern}'  Should Match Regexp  ${message}  ${pattern}

Has Not Been Cut
    [Arguments]  ${testname}
    ${test} =  Get Test Case  ${testname}
    Should Not Contain  ${test.message}  Message content over


