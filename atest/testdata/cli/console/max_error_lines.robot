*** Settings ***
Library  Exceptions

*** Test Cases ***
50 X 1 Message Under The Limit
    Fail With Long Message  50  1

100 X 1 Message Under The Limit
    Fail With Long Message  100  1

50 X 10 Message Under The Limit
    Fail With Long Message  50  10

150 X 19 Message Under The Limit
    Fail With Long Message  150  9

20 X 30 Message On The Limit
    Fail With Long Message  20  30

150 X 15 Message On The Limit
    Fail With Long Message  150  15

2340 X 1 Message On The Limit
    Fail With Long Message  2340  1

79 X 30 Message Over The Limit
    Fail With Long Message  79  30

8 X 31 Message Over The Limit
    Fail With Long Message  8  31

400 X 7 Message Over The Limit
    Fail With Long Message  400  7

2341 X 1 Message Over The Limit
    Fail With Long Message  2341  1

Multiple short errors
    :FOR  ${index}  IN RANGE  1  100
    \   Raise Continuable Failure   Failure number ${index}

Two long errors
    ${err}=  Get Long Message   40  50
    Raise Continuable Failure  ${err}
    Raise Continuable Failure  ${err.replace(' ', '~')}


*** Keywords ***
Fail With Long Message
    [Arguments]  ${line_length}=80  ${line_count}=1
    ${msg} =  Get Long Message  ${line_length}  ${line_count}
    Comment  Sanity check.  Must have triple quotes because  ${msg} contains newlines.
    Should Be True  len("""${msg}""") == ${line_length} * ${line_count}  Wrong length
    Fail  ${msg}

Get Long Message
    [Arguments]  ${line_length}=80  ${line_count}=1
    ${lines} =  Evaluate  [ str(i * ${line_length} + 1) for i in range(${line_count}) ]
    ${lines} =  Evaluate  [ line.ljust(${line_length} - 4) for line in ${lines} ]
    ${msg} =  Evaluate  "END\\n".join(${lines})
    ${total_chars} =  Evaluate  ${line_length} * ${line_count}
    ${msg} =  Evaluate  """${msg}"""[:-len("${total_chars}")] + " " * 4 + "${total_chars}"
    [Return]  ${msg}

