import requests
from dotenv import load_dotenv
import os

load_dotenv()  # Load n8n creds from .env (add your Railway URL/API key)

def run_daddy_agent(query):
    # Placeholder: Post to n8n webhook (replace with your Telegram trigger URL or n8n exec endpoint)
    n8n_url = os.getenv('N8N_WEBHOOK_URL')  # e.g., your Railway webhook
    payload = {'message': {'text': query}}  # Mimic Telegram input
    response = requests.post(n8n_url, json=payload)
    return response.json().get('text', 'Error')

if __name__ == "__main__":
    print(run_daddy_agent("Plan my budget for health tracking."))  # Test delegation
