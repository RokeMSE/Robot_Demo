*** Settings ***
Documentation     A generic and dynamic test suite that uses an AI Helper to generate
...               and execute tests for any application.

# --- Step 1: Add Your Libraries ---
# Add the UI automation library for your target application (Ex: FlaUILibrary for Windows,
# SeleniumLibrary for web, AppiumLibrary for mobile).
# Library           FlaUILibrary
# Library           SeleniumLibrary

# Standard libraries that are almost always useful.
Library           OperatingSystem
Library           Collections

# This is the path to your custom Python AI helper file.
Library           Resources/GenericAiHelper.py

*** Variables ***
# --- Step 2: Define Your Application Variables ---
# Define variables for your application, such as the app name, URL, or file path.
# Example for a desktop app:
# ${APP_NAME}       YourApp.exe
# Example for a web app:
# ${BROWSER}        Chrome
# ${START_URL}      http://your-website.com

*** Test Cases ***
Dynamically Execute AI-Generated Tests
    [Documentation]    This test generates test cases from an AI and executes them dynamically.
    
    # --- Step 3: Create Your AI Prompt ---
    # This is where you define what you want the AI to test.
    # Be very specific about the JSON structure, valid actions, and element locators.
    # This prompt is passed directly to the `Generate Dynamic Test Cases From AI` keyword.
    ${prompt}=    Set Variable    
    ...    You are a Software Quality Assurance Engineer.
    ...    Your task is to generate 3 test cases for a target application.
    ...    Format the output as a JSON array of objects.
    ...    Each object must have "title", "description", and "steps".
    ...    Each step object must have "action" and "value".
    ...    The valid actions are: "click_element", "input_text", "verify_element_text".
    ...    Provide the locators (Ex: XPath, ID) for the 'value' of each action.
    ...    IMPORTANT: Ensure the output is a single, valid JSON array only.

    # Call the AI to generate the test cases based on the prompt above.
    ${test_cases}=    Generate Dynamic Test Cases From AI    ${prompt}
    
    ${test_cases_count}=    Get Length    ${test_cases}
    Log    Received ${test_cases_count} test cases from AI.    console=yes

    # Loop through each test case returned by the AI.
    FOR    ${test_case}    IN    @{test_cases}
        Log To Console    \n--- Running AI Test: ${test_case['title']} ---
        Log    Description: ${test_case['description']}
        Run Single AI Test Case    ${test_case['steps']}
    END

*** Keywords ***
Run Single AI Test Case
    [Arguments]    ${steps}
    # --- Step 4: Add Your Setup Keyword ---
    # This keyword should prepare the application for the test.
    # For example: launch the app, open a browser, or reset state.
    Setup Application For Test

    # This loop executes each step from the AI's response.
    # The 'Run Keyword If' statements map the "action" from the JSON
    # to your custom keywords below.
    FOR    ${step}    IN    @{steps}
        Run Keyword If    '${step['action']}' == 'click_element'        Click Element        ${step['value']}
        Run Keyword If    '${step['action']}' == 'input_text'           Input Text Into Element    ${step['locator']}    ${step['text']}
        Run Keyword If    '${step['action']}' == 'verify_element_text'  Verify Element Text    ${step['locator']}    ${step['expected_text']}
    END

    # --- Step 5: Add Your Teardown Keyword ---
    # This keyword should clean up after the test.
    # For example: close the application or browser.
    Teardown Application After Test

# --- Step 6: Implement Your Custom Keywords ---
# These are the keywords that perform the actual interactions with your application.
# You must adapt these to use the correct library (Ex: Selenium, FlaUI) and locators.

Setup Application For Test
    # Example for a desktop app:
    # Launch Application    ${APP_NAME}
    # Example for a web app:
    # Open Browser    ${START_URL}    ${BROWSER}
    Log    This keyword should contain your application setup logic.
    Pass Execution    Not implemented yet.

Click Element
    [Arguments]    ${locator}
    # Example for FlaUI:
    # Click    xpath=${locator}
    # Example for Selenium:
    # Click Element    xpath=${locator}
    Log    Clicking element with locator: ${locator}
    Pass Execution    Not implemented yet.

Input Text Into Element
    [Arguments]    ${locator}    ${text_to_input}
    # Example for FlaUI or Selenium:
    # Input Text    xpath=${locator}    ${text_to_input}
    Log    Inputting '${text_to_input}' into element with locator: ${locator}
    Pass Execution    Not implemented yet.

Verify Element Text
    [Arguments]    ${locator}    ${expected_text}
    # Example for FlaUI:
    # Element Text Should Be    xpath=${locator}    ${expected_text}
    # Example for Selenium:
    # Element Text Should Be    xpath=${locator}    ${expected_text}
    Log    Verifying element at '${locator}' contains text '${expected_text}'
    Pass Execution    Not implemented yet.

Teardown Application After Test
    # Example for a desktop app:
    # Close Application    ${APP_NAME}
    # Example for a web app:
    # Close Browser
    Log    This keyword should contain your application teardown logic.
    Pass Execution    Not implemented yet.