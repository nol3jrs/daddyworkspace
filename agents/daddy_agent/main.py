import requests
from dotenv import load_dotenv
import os
import sys

# Add agents path to sys.path for relative imports
sys.path.append(os.path.dirname(os.path.dirname(__file__)))

load_dotenv('config/.env')  # Explicit path to your .env file

def delegate_task(query):
    print(f"Processing query: {query}")  # Debug: Show input
    if 'budget' in query.lower():
        print("Routing to CFO path")
        from cfo_agent.main import cfo_budget_plan  # Relative import fix
        return cfo_budget_plan(query)
    elif 'todo' in query.lower() or 'manage' in query.lower():
        print("Routing to Datagent path")
        return "Delegated to Datagent: Todo management started."
    else:
        print("Fallback to Telegram/n8n query")
        return run_telegram_query(query)

def run_telegram_query(query):
    bot_token = os.getenv('TELEGRAM_BOT_TOKEN')
    chat_id = os.getenv('TELEGRAM_CHAT_ID', '5805620899')  # Default to your chat ID
    print(f"Loaded bot_token: {'Set' if bot_token else 'Missing'}")  # Debug: Check env
    print(f"Loaded chat_id: {chat_id}")
    if not bot_token:
        return "Error: Missing TELEGRAM_BOT_TOKEN in .env"
    url = f"https://api.telegram.org/bot{bot_token}/sendMessage"
    payload = {'chat_id': chat_id, 'text': query}
    try:
        response = requests.post(url, json=payload)
        response.raise_for_status()
        print(f"Response status: {response.status_code}")  # Debug: HTTP status
        return "Message sent to Telegram (n8n will process and respond there)."
    except Exception as e:
        return f"Error: {str(e)}"

if __name__ == "__main__":
    test_query = "Plan my budget for health tracking."  # Test CFO routing
    result = delegate_task(test_query)
    print(f"Final result: {result}")
