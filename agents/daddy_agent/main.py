import requests
from dotenv import load_dotenv
import os

load_dotenv()  # Loads from config/.env

def delegate_task(query):
    print(f"Processing query: {query}")  # Debug: Show input
    if 'budget' in query.lower():
        print("Routing to CFO path")
        return "Delegated to CFO Agent: Budget planning initiated."
    elif 'todo' in query.lower() or 'manage' in query.lower():
        print("Routing to Datagent path")
        return "Delegated to Datagent: Todo management started."
    else:
        print("Fallback to Telegram/n8n query")
        return run_telegram_query(query)

def run_telegram_query(query):
    bot_token = os.getenv('TELEGRAM_BOT_TOKEN')
    chat_id = os.getenv('TELEGRAM_CHAT_ID')
    print(f"Loaded bot_token: {'Set' if bot_token else 'Missing'}")  # Debug: Check env
    print(f"Loaded chat_id: {'Set' if chat_id else 'Missing'}")
    if not bot_token or not chat_id:
        return "Error: Missing TELEGRAM_BOT_TOKEN or TELEGRAM_CHAT_ID in .env"
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
    test_query = "Plan my budget for health tracking."
    result = delegate_task(test_query)
    print(f"Final result: {result}")
