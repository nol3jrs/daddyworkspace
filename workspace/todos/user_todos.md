# User TODOs for DaddyWorkspace Build-Out
## High Priority (Core Alignment & Efficiency)
- [ ] Share an example n8n workflow JSON from your Railway instance (paste here or upload) to prototype Daddy Agent delegation.
- [ ] Define Daddy Agent's core delegation rules in requirements/agent_specific/daddy_agent_reqs.md (e.g., route QoL queries to sub-agents like CFO for budgets or datagent for personal todos).
- [x] Implement basic Python boilerplate in agents/daddy_agent/main.py for task routing (use LangChain for chains; test with sample input like "Manage my daily todos").
- [ ] Integrate voice prototype: Extend utils/voice_io.py with speechrecognition/gtts, linking to prototypes/grok_voice_interaction_html.html for hands-free QoL input.
- [ ] Review behavioral_statement.md for any tweaks to ensure QoL focus (e.g., add rule for datagent handling life todos separately from project ones).
- [ ] Test fallback to Telegram/n8n with real creds.

## Medium Priority (Beneficial Enhancements & Optimization)
- [ ] Populate qol_domains/ with initial JSONs (e.g., health.json: {"ideas": ["Fitness tracking workflow", "Voice reminders via datagent"]} ) to map "endless possibilities."
- [ ] Set up dependencies: Run `poetry init` and add essentials (langchain, speechrecognition, etc.) in pyproject.toml; test with `poetry install`.
- [ ] Create a simple n8n hook script in scripts/n8n_export.py to simulate manual JSON imports (future: automate if API access possible).
- [ ] Add tests: Flesh out tests/test_daddy_agent.py with pytest for delegation logic (e.g., assert routes budget query to CFO stub).
- [ ] Budget check: Update budgets/budget_tracker.md with estimates (e.g., Railway costs ~$10/mo; free tiers for APIs).

## Low Priority (Scalability & Polish)
- [ ] Design hierarchy diagram: Create agent_hierarchy.xml in designs/ using Draw.IO (Daddy → CFO, CIO, COO, datagent).
- [ ] Version first milestone: After basic Daddy Agent runs, tag it (`git tag v0.1-daddy && git push --tags`).
- [ ] Explore datagent stub: Add agents/datagent/ folder with placeholder.md describing personal todo management (e.g., sync with Google Calendar for QoL).
- [ ] Whiteboard capture: Log this convo in whiteboard/session_002.md for reference.
- [ ] Ideas backlog: Dump any new QoL concepts (e.g., "Integrate with Grok API for queries") into ideas/new_agent_idea.json.
