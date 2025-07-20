import os
import json
import google.generativeai as genai
from robot.api.deco import keyword
from robot.api import logger
from dotenv import load_dotenv

# --- Step 1: Environment Setup ---
load_dotenv()

# --- Step 2: AI Model Configuration ---
""" 
For the API key, create a .env file in the root directory of your project with the following content:
GEMINI_API_KEY=your_api_key_here
"""
try:
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        raise ValueError("GEMINI_API_KEY environment variable not found. Please create a .env file and add it.")
    
    # Configure with the new API
    genai.configure(api_key=api_key)
    
    # Initialize the model
    model = genai.GenerativeModel('gemini-2.5-flash')
    
    # Configure generation parameters (generic)
    generation_config = {
        "temperature": 0.5,
        "top_p": 1,
        "top_k": 32,
        "max_output_tokens": 4096,
    }
    
    # Configure safety settings (also generic)
    safety_settings = [
        {
            "category": "HARM_CATEGORY_HARASSMENT",
            "threshold": "BLOCK_ONLY_HIGH"
        },
        {
            "category": "HARM_CATEGORY_HATE_SPEECH",
            "threshold": "BLOCK_ONLY_HIGH"
        },
        {
            "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
            "threshold": "BLOCK_ONLY_HIGH"
        },
        {
            "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
            "threshold": "BLOCK_ONLY_HIGH"
        },
    ]
    
except Exception as e:
    logger.error(f"Fatal Error configuring Gemini API: {e}")
    model = None

# --- Step 3: Basline Keyword Definitions ---
@keyword("Ask AI A General Question")
def ask_ai_a_general_question(prompt: str) -> str:
    """Sends a general prompt to the AI and returns its text response."""
    if not model:
        return "Error: AI model not initialized. Check API key and configuration."
    try:
        response = model.generate_content(
            prompt,
            generation_config=generation_config,
            safety_settings=safety_settings
        )
        return response.text
    except Exception as e:
        logger.error(f"Error communicating with AI: {e}")
        return f"Error communicating with AI: {e}"

@keyword("Generate Structured Data From AI")
def generate_structured_data_from_ai(topic: str, structure_description: str) -> str:
    """Asks the AI to generate data in a specific format (like JSON) for a given topic."""
    if not model:
        return "Error: AI model not initialized."
    
    # Get the custom prompt with the topic and structure description based on your needs
    """ NOTICE: Use something like Windows 'Accessibility Insights' to get the Components Xpath name and structure. """
    custom_prompt = (
        "You are an expert test data generator. "
        f"Create a realistic but fake data structure for: '{topic}'. "
        f"The structure should be: {structure_description}. "
        "IMPORTANT: Only return the structured data (e.g., the JSON object) and nothing else. "
        "No explanatory text or markdown formatting."
    )
    
    try:
        response = model.generate_content(
            custom_prompt,
            generation_config=generation_config,
            safety_settings=safety_settings
        )
        cleaned_response = response.text.strip().replace("```json", "").replace("```", "")
        return cleaned_response
    except Exception as e:
        logger.error(f"Error generating test data with AI: {e}")
        return f'{{"error": "Error generating test data with AI: {e}"}}'

@keyword("Generate Dynamic Test Cases From AI")
def generate_dynamic_test_cases_from_ai(prompt_for_tests: str) -> list:
    """Generates a list of test cases based on a detailed prompt."""
    if not model:
        return []

    try:
        response = model.generate_content(
            prompt_for_tests,
            generation_config=generation_config,
            safety_settings=safety_settings
        )
        json_string = response.text.strip().replace("```json", "").replace("```", "")
        logger.info(f"Cleaned JSON response from AI:\n{json_string}")
        
        test_cases = json.loads(json_string)
        return test_cases
    except Exception as e:
        logger.error(f"Error communicating with or parsing JSON from AI: {e}")
        raise