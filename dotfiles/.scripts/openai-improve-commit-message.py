from openai import OpenAI
import sys
import os

def generate_commit_message(git_diff):
    prompt = f"""
        Generate a commit message using the git diff below.

        Git diff: \"\"\"
        {git_diff}
        \"\"\"

        Output format:
        <title>

        <description>
    """
    return create_chat_completion(prompt)

def improve_commit_message(commit_message, git_diff):
    prompt = f"""
        Improve the commit message below.

        Commit message: \"\"\"
        {commit_message}
        \"\"\"

        Git diff: \"\"\"
        {git_diff}
        \"\"\"

        Output format: 
        <title>

        <description>
    """
    return create_chat_completion(prompt)

def create_chat_completion(prompt):
    response = OpenAI().chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": "You are a 10x developer."},
            {"role": "user", "content": prompt},
        ]
    )
    # print(f"Total tokens: {response.usage.total_tokens}")
    return response.choices[0].message.content.strip()


if __name__ == "__main__":
    # Read commit message and git diff from arguments
    commit_msg = sys.argv[1]
    git_diff = sys.argv[2]
    
    # Improve the commit message
    print(improve_commit_message(commit_msg, git_diff)

