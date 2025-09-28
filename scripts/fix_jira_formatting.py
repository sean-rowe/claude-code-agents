#!/usr/bin/env python3
"""
Script to fix JIRA formatting issues in OPS project
Converts markdown to JIRA wiki markup and adds proper sections
"""

import json
import subprocess
import re
import sys

def run_acli_command(cmd):
    """Run ACLI command and return result"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        if result.returncode == 0:
            return result.stdout.strip()
        else:
            print(f"Error running command: {cmd}")
            print(f"Error: {result.stderr}")
            return None
    except Exception as e:
        print(f"Exception running command: {cmd}")
        print(f"Exception: {e}")
        return None

def convert_markdown_to_jira_wiki(text):
    """Convert markdown formatting to JIRA wiki markup"""
    if not text:
        return text

    # Convert **bold** to *bold*
    text = re.sub(r'\*\*(.*?)\*\*', r'*\1*', text)

    # Convert `code` to {{code}}
    text = re.sub(r'`([^`]+)`', r'{{\1}}', text)

    # Convert # Header to h1. Header
    text = re.sub(r'^# (.+)$', r'h1. \1', text, flags=re.MULTILINE)

    # Convert ## Header to h2. Header
    text = re.sub(r'^## (.+)$', r'h2. \1', text, flags=re.MULTILINE)

    # Convert ### Header to h3. Header
    text = re.sub(r'^### (.+)$', r'h3. \1', text, flags=re.MULTILINE)

    # Convert - bullet to * bullet
    text = re.sub(r'^- (.+)$', r'* \1', text, flags=re.MULTILINE)

    # Convert [link](url) to [link|url]
    text = re.sub(r'\[([^\]]+)\]\(([^)]+)\)', r'[\1|\2]', text)

    return text

def create_proper_jira_description(original_text):
    """Create properly formatted JIRA description with sections"""

    # Convert markdown formatting
    text = convert_markdown_to_jira_wiki(original_text)

    # Extract scenario name if available
    scenario_match = re.search(r'\*Scenario\*:\s*(.+?)(?:\n|$)', text)
    scenario_name = scenario_match.group(1) if scenario_match else "User Story"

    # Extract feature name if available
    feature_match = re.search(r'\*Feature\*:\s*(.+?)(?:\n|$)', text)
    feature_name = feature_match.group(1) if feature_match else "Feature"

    # Extract domain if available
    domain_match = re.search(r'\*Domain\*:\s*(.+?)(?:\n|$)', text)
    domain_name = domain_match.group(1) if domain_match else "Domain"

    # Extract gherkin scenarios
    gherkin_match = re.search(r'{{gherkin\n(.*?)\n}}', text, re.DOTALL)
    if not gherkin_match:
        gherkin_match = re.search(r'```gherkin\n(.*?)\n```', text, re.DOTALL)

    gherkin_content = gherkin_match.group(1) if gherkin_match else ""

    # Build new description
    new_description = f"""h2. User Story
{scenario_name}

h2. Feature Area
{feature_name}

h2. Domain
{domain_name}

h2. Acceptance Criteria
{{code:language=gherkin}}
{gherkin_content}
{{code}}

h2. Definition of Done
* [ ] Gherkin scenario implemented
* [ ] Unit tests passing
* [ ] Integration tests passing
* [ ] Code reviewed and approved
* [ ] Documentation updated
* [ ] Deployed to staging environment

h2. Labels
Add labels: {{bdd}}, {{gherkin}}, {{{domain_name}}}
"""

    return new_description.strip()

def get_issue_details(issue_key):
    """Get issue details via ACLI"""
    cmd = f"acli jira workitem view {issue_key} --json"
    result = run_acli_command(cmd)
    if result:
        try:
            return json.loads(result)
        except json.JSONDecodeError:
            print(f"Failed to parse JSON for {issue_key}")
            return None
    return None

def update_issue_description(issue_key, new_description):
    """Update issue description via ACLI"""
    # Write description to temp file to handle special characters
    temp_file = f"/tmp/desc_{issue_key}.txt"
    with open(temp_file, 'w') as f:
        f.write(new_description)

    cmd = f"acli jira workitem edit --key {issue_key} --description-file {temp_file} --yes"
    result = run_acli_command(cmd)

    # Clean up temp file
    try:
        import os
        os.remove(temp_file)
    except:
        pass

    return result is not None

def main():
    """Main function to process all issues"""
    print("Starting JIRA formatting fixes for OPS project...")

    # Get list of task issues to fix (all task issues from OPS-15 onward, excluding already processed ones)
    cmd = "acli jira workitem search --jql \"project = OPS AND issuetype = Task AND key >= OPS-15 AND key != OPS-46 AND key != OPS-47 AND key != OPS-48\" --json"
    result = run_acli_command(cmd)

    if not result:
        print("Failed to get issue list")
        return

    try:
        issues_data = json.loads(result)
        # Handle case where issues_data is a list directly
        if isinstance(issues_data, list):
            # Filter out None values and get keys from valid issues
            issue_keys = [issue['key'] for issue in issues_data if issue and 'key' in issue]
        else:
            # It's a dictionary, get issues from it
            issue_keys = [issue['key'] for issue in issues_data.get('issues', []) if issue and 'key' in issue]
    except (json.JSONDecodeError, KeyError, TypeError) as e:
        print(f"Failed to parse issues JSON: {e}")
        return

    print(f"Found {len(issue_keys)} issues to process")

    success_count = 0
    error_count = 0

    for i, issue_key in enumerate(issue_keys):
        print(f"Processing {issue_key} ({i+1}/{len(issue_keys)})...")

        # Get current issue details
        issue_details = get_issue_details(issue_key)
        if not issue_details:
            print(f"  Failed to get details for {issue_key}")
            error_count += 1
            continue

        # Extract current description text
        description_obj = issue_details.get('fields', {}).get('description', {})
        current_text = ""

        if description_obj and 'content' in description_obj:
            for content_block in description_obj['content']:
                if content_block.get('type') == 'paragraph':
                    for inline_content in content_block.get('content', []):
                        if inline_content.get('type') == 'text':
                            current_text += inline_content.get('text', '')

        if not current_text.strip():
            print(f"  No description content found for {issue_key}")
            continue

        # Create new formatted description
        new_description = create_proper_jira_description(current_text)

        # Update the issue
        if update_issue_description(issue_key, new_description):
            print(f"  ✓ Successfully updated {issue_key}")
            success_count += 1
        else:
            print(f"  ✗ Failed to update {issue_key}")
            error_count += 1

    print(f"\nCompleted processing:")
    print(f"  Successfully updated: {success_count}")
    print(f"  Errors: {error_count}")
    print(f"  Total processed: {success_count + error_count}")

if __name__ == "__main__":
    main()