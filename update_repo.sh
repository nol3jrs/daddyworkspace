#!/bin/bash
cat > DaddyAgent.json << 'JSON'
{
  "name": "DaddyAgent",
  "nodes": [
    {
      "parameters": {
        "updates": ["message"],
        "additionalFields": {}
      },
      "type": "n8n-nodes-base.telegramTrigger",
      "typeVersion": 1.2,
      "position": [-1808, 160],
      "id": "162692ab-a30d-4a1a-a225-7218a44ed929",
      "name": "Telegram Trigger",
      "webhookId": "16d64522-2814-4074-9b7c-b19052d53b40",
      "alwaysOutputData": true,
      "credentials": {
        "telegramApi": {
          "id": "VeWEKodxZWPDoKiQ",
          "name": "Telegram account"
        }
      },
      "onError": "continueRegularOutput"
    },
    {
      "parameters": {
        "assignments": {
          "assignments": [
            {
              "id": "set-limit-value",
              "name": "memory_limit",
              "value": "={{ Math.min(Math.max(Number($json.message.text.startsWith('/setlimit') ? ($json.message.text.split(' ')[1].match(/^[0-9]+$/) ? $json.message.text.split(' ')[1] : 20) : 20) || 20, 1), 50) }}",
              "type": "number"
            }
          ]
        },
        "options": {}
      },
      "type": "n8n-nodes-base.set",
      "typeVersion": 3.4,
      "position": [-1664, 80],
      "id": "516144c4-9344-4716-8d32-b34d0d82734f",
      "name": "Set Limit Value",
      "alwaysOutputData": true,
      "onError": "continueRegularOutput"
    },
    {
      "parameters": {
        "operation": "executeQuery",
        "query": "INSERT INTO memory_limit_config (chat_id, memory_limit) VALUES ({{ $('Telegram Trigger').item.json.message.chat.id }}, {{ $('Set Limit Value').item.json.memory_limit }}) ON CONFLICT (chat_id) DO UPDATE SET memory_limit = EXCLUDED.memory_limit, timestamp = CURRENT_TIMESTAMP;",
        "options": {}
      },
      "type": "n8n-nodes-base.postgres",
      "typeVersion": 2.6,
      "position": [-1520, 80],
      "id": "de4f84b2-f74a-4629-9d92-88389ea3fd59",
      "name": "Set Persistent Limit",
      "alwaysOutputData": true,
      "credentials": {
        "postgres": {
          "id": "6P0ERsVEGvjeC73P",
          "name": "Postgres account"
        }
      },
      "onError": "continueRegularOutput"
    },
    {
      "parameters": {
        "operation": "executeQuery",
        "query": "SELECT memory_limit FROM memory_limit_config WHERE chat_id = $1 ORDER BY timestamp DESC LIMIT 1;",
        "options": {}
      },
      "type": "n8n-nodes-base.postgres",
      "typeVersion": 2.6,
      "position": [-1360, 80],
      "id": "a2350e76-d6d4-4d72-8d3a-e93b71a9770b",
      "name": "Load Persistent Limit",
      "alwaysOutputData": true,
      "credentials": {
        "postgres": {
          "id": "6P0ERsVEGvjeC73P",
          "name": "Postgres account"
        }
      },
      "onError": "continueRegularOutput"
    },
    {
      "parameters": {
        "operation": "executeQuery",
        "query": "SELECT STRING_AGG(CONCAT(role, ': ', content), '\\n' ORDER BY timestamp ASC) AS system_prompt \nFROM (SELECT role, content, timestamp FROM core_memory \n      WHERE content IS NOT NULL AND content != '' AND content != 'undefined' \n      ORDER BY timestamp DESC LIMIT {{ $('Load Persistent Limit').item.json.memory_limit || 20 }}) AS sub",
        "options": {}
      },
      "type": "n8n-nodes-base.postgres",
      "typeVersion": 2.6,
      "position": [-1200, 80],
      "id": "a02cc455-8ae4-49e5-8887-2b2ef212ab95",
      "name": "Postgress Memory Loader",
      "alwaysOutputData": true,
      "credentials": {
        "postgres": {
          "id": "6P0ERsVEGvjeC73P",
          "name": "Postgres account"
        }
      },
      "onError": "continueRegularOutput"
    },
    {
      "parameters": {
        "assignments": {
          "assignments": [
            {
              "id": "06303525-b6ba-426c-b740-c0b22b876344",
              "name": "Original Message",
              "value": "={{ $('Telegram Trigger').item.json.message.text }}",
              "type": "string"
            },
            {
              "id": "397b5473-8a36-4b6c-8906-9dba46184084",
              "name": "system_prompt",
              "value": "={{ $json.system_prompt }}",
              "type": "string"
            }
          ]
        },
        "options": {}
      },
      "type": "n8n-nodes-base.set",
      "typeVersion": 3.4,
      "position": [-992, -16],
      "id": "df0490c2-82f1-4aa0-968b-76cce3a0f37c",
      "name": "Memory Rebuild",
      "alwaysOutputData": true,
      "onError": "continueRegularOutput"
    },
    {
      "parameters": {
        "promptType": "define",
        "text": "={{ $('Telegram Trigger').item.json.message.text }}",
        "messages": {
          "messageValues": [
            {
              "message": "={{ $('Memory Rebuild').item.json.system_prompt }}"
            }
          ]
        },
        "batching": {}
      },
      "type": "@n8n/n8n-nodes-langchain.chainLlm",
      "typeVersion": 1.7,
      "position": [-672, -144],
      "id": "ba8bb9bd-6bc3-412d-8a82-eae8b8e75b21",
      "name": "Basic LLM Chain",
      "alwaysOutputData": true,
      "onError": "continueRegularOutput"
    },
    {
      "parameters": {
        "model": "=grok-4-0709",
        "options": {}
      },
      "type": "@n8n/n8n-nodes-langchain.lmChatXAiGrok",
      "typeVersion": 1,
      "position": [-608, 80],
      "id": "5fb0a7b4-0cbf-4b4c-9805-c0d5e3582dff",
      "name": "xAI Grok Chat Model",
      "credentials": {
        "xAiApi": {
          "id": "AyY7ypBBubODV5YZ",
          "name": "xAi account"
        }
      }
    },
    {
      "parameters": {
        "assignments": {
          "assignments": [
            {
              "id": "37eb131a-18b1-4ed6-bcdb-de2bf8d0bf8e",
              "name": "text",
              "value": "={{ $('Basic LLM Chain').item.json.text.replace(/\\s*This message was sent automatically with n8n\\s*/g, '') }}",
              "type": "string"
            }
          ]
        },
        "options": {}
      },
      "type": "n8n-nodes-base.set",
      "typeVersion": 3.4,
      "position": [-352, -112],
      "id": "581fb560-4ae8-4252-86f4-29dedf6efa43",
      "name": "Debug LLM Output",
      "alwaysOutputData": false,
      "onError": "continueRegularOutput"
    },
    {
      "parameters": {
        "chatId": "={{ $('Telegram Trigger').item.json.message.chat.id }}",
        "text": "={{ $json.text.replace(/\\s*This message was sent automatically with n8n\\s*/g, '') + '||CLEAN||' }}",
        "additionalFields": {}
      },
      "type": "n8n-nodes-base.telegram",
      "typeVersion": 1.2,
      "position": [-128, -112],
      "id": "b3f8d8b0-123c-47df-b695-5b51cf54a334",
      "name": "Send a text message",
      "webhookId": "b5ce390b-0482-43a5-8c0b-a673edbcbd4a",
      "alwaysOutputData": true,
      "credentials": {
        "telegramApi": {
          "id": "VeWEKodxZWPDoKiQ",
          "name": "Telegram account"
        }
      },
      "onError": "continueRegularOutput"
    },
    {
      "parameters": {
        "operation": "executeQuery",
        "query": "INSERT INTO core_memory (role, content) VALUES ('assistant', '{{ $('Debug Assistant Input').item.json.assistant_text || '' }}');",
        "options": {}
      },
      "type": "n8n-nodes-base.postgres",
      "typeVersion": 2.6,
      "position": [-80, 224],
      "id": "461546f2-d361-4d6c-aef2-feaa5ab810de",
      "name": "Postgres - Assistant Insert",
      "alwaysOutputData": true,
      "credentials": {
        "postgres": {
          "id": "6P0ERsVEGvjeC73P",
          "name": "Postgres account"
        }
      },
      "onError": "continueRegularOutput"
    },
    {
      "parameters": {
        "operation": "executeQuery",
        "query": "INSERT INTO core_memory (role, content) VALUES ('user', $1);",
        "options": {}
      },
      "type": "n8n-nodes-base.postgres",
      "typeVersion": 2.6,
      "position": [-1152, 368],
      "id": "bbb56985-296e-41f3-b827-3509bf24a3ca",
      "name": "Postgres - User Insert",
      "alwaysOutputData": true,
      "credentials": {
        "postgres": {
          "id": "6P0ERsVEGvjeC73P",
          "name": "Postgres account"
        }
      },
      "onError": "continueRegularOutput"
    },
    {
      "parameters": {
        "assignments": {
          "assignments": [
            {
              "id": "3146d932-ff52-4d3b-8e65-b3614bc68243",
              "name": "assistant_text",
              "value": "={{ $json.result.text.replace(/\\n*This message was sent automatically with n8n/g, '').replace(/'/g, \"''\") || 'No text available' }}",
              "type": "string"
            }
          ]
        },
        "options": {}
      },
      "type": "n8n-nodes-base.set",
      "typeVersion": 3.4,
      "position": [-288, 224],
      "id": "c6142a72-d912-4d5a-ac5f-48ef7f903ae0",
      "name": "Debug Assistant Input",
      "alwaysOutputData": true,
      "executeOnce": false,
      "onError": "continueRegularOutput"
    }
  ],
  "pinData": {},
  "connections": {
    "xAI Grok Chat Model": {
      "ai_languageModel": [
        [
          {
            "node": "Basic LLM Chain",
            "type": "ai_languageModel",
            "index": 0
          }
        ]
      ]
    },
    "Telegram Trigger": {
      "main": [
        [
          {
            "node": "Set Limit Value",
            "type": "main",
            "index": 0
          },
          {
            "node": "Postgres - User Insert",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Set Limit Value": {
      "main": [
        [
          {
            "node": "Set Persistent Limit",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Set Persistent Limit": {
      "main": [
        [
          {
            "node": "Load Persistent Limit",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Load Persistent Limit": {
      "main": [
        [
          {
            "node": "Postgress Memory Loader",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Postgress Memory Loader": {
      "main": [
        [
          {
            "node": "Memory Rebuild",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Memory Rebuild": {
      "main": [
        [
          {
            "node": "Basic LLM Chain",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Basic LLM Chain": {
      "main": [
        [
          {
            "node": "Debug LLM Output",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Debug LLM Output": {
      "main": [
        [
          {
            "node": "Send a text message",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Send a text message": {
      "main": [
        [
          {
            "node": "Debug Assistant Input",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Debug Assistant Input": {
      "main": [
        [
          {
            "node": "Postgres - Assistant Insert",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  },
  "active": false,
  "settings": {
    "executionOrder": "v1",
    "timezone": "America/Chicago",
    "saveExecutionProgress": true,
    "callerPolicy": "workflowsFromSameOwner",
    "errorWorkflow": "bIcur3RnHIwhbQrz"
  },
  "versionId": "e7bd47d3-df70-44a7-bdff-1eb7e96c0b5b",
  "meta": {
    "templateCredsSetupCompleted": true,
    "instanceId": "8a23f4a414eab2511e2d449872efcd21e85a0679af7fc702f715235be7579732"
  },
  "id": "bIcur3RnHIwhbQrz",
  "tags": []
}
JSON
cat > REQUIREMENTS.md << 'MD'
Met:
- Telegram trigger
- Dynamic memory limit with /setlimit
- LLM chain
- DB inserts
- Remove n8n suffix with regex
Pending:
- Replace Send a text message with HTTP Request
- Test dynamic memory limit in production
- Activate workflow
MD
cat > DESIGN.drawio.xml << 'XML'
<mxfile host="app.diagrams.net"><diagram id="diagram_1" name="Page-1"><mxGraphModel><root><mxCell id="0"/><mxCell id="1" parent="0"/><mxCell id="2" value="Telegram Trigger" style="rounded=1;whiteSpace=wrap;html=1;" vertex="1" parent="1"><mxGeometry x="100" y="100" width="120" height="60" as="geometry"/></mxCell><mxCell id="3" value="Set Limit Value" style="rounded=1;whiteSpace=wrap;html=1;" vertex="1" parent="1"><mxGeometry x="250" y="100" width="120" height="60" as="geometry"/></mxCell><mxCell id="4" value="Set Persistent Limit" style="rounded=1;whiteSpace=wrap;html=1;" vertex="1" parent="1"><mxGeometry x="400" y="100" width="120" height="60" as="geometry"/></mxCell><mxCell id="5" value="Load Persistent Limit" style="rounded=1;whiteSpace=wrap;html=1;" vertex="1" parent="1"><mxGeometry x="550" y="100" width="120" height="60" as="geometry"/></mxCell><mxCell id="6" value="Postgres Memory Loader" style="rounded=1;whiteSpace=wrap;html=1;" vertex="1" parent="1"><mxGeometry x="700" y="100" width="120" height="60" as="geometry"/></mxCell><mxCell id="7" value="Memory Rebuild" style="rounded=1;whiteSpace=wrap;html=1;" vertex="1" parent="1"><mxGeometry x="850" y="100" width="120" height="60" as="geometry"/></mxCell><mxCell id="8" value="Basic LLM Chain" style="rounded=1;whiteSpace=wrap;html=1;" vertex="1" parent="1"><mxGeometry x="1000" y="100" width="120" height="60" as="geometry"/></mxCell><mxCell id="9" value="xAI Grok Chat Model" style="rounded=1;whiteSpace=wrap;html=1;" vertex="1" parent="1"><mxGeometry x="1000" y="200" width="120" height="60" as="geometry"/></mxCell><mxCell id="10" value="Debug LLM Output" style="rounded=1;whiteSpace=wrap;html=1;" vertex="1" parent="1"><mxGeometry x="1150" y="100" width="120" height="60" as="geometry"/></mxCell><mxCell id="11" value="Send a Text Message" style="rounded=1;whiteSpace=wrap;html=1;" vertex="1" parent="1"><mxGeometry x="1300" y="100" width="120" height="60" as="geometry"/></mxCell><mxCell id="12" value="Debug Assistant Input" style="rounded=1;whiteSpace=wrap;html=1;" vertex="1" parent="1"><mxGeometry x="1300" y="200" width="120" height="60" as="geometry"/></mxCell><mxCell id="13" value="Postgres Inserts" style="rounded=1;whiteSpace=wrap;html=1;" vertex="1" parent="1"><mxGeometry x="1450" y="200" width="120" height="60" as="geometry"/></mxCell><mx
