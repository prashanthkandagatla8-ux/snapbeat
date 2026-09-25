import os
import re

dir_path = r'C:\MyProjects\snapbeat_flutter\lib'

replacements = {
    r'AppColors\.amberJewel': 'const Color(0xFFFFFFFF)',
    r'AppColors\.amberGoldLight': 'const Color(0xFFFFFFFF)',
    r'AppColors\.amberGoldDark': 'const Color(0xFFAAAAAA)',
    r'AppColors\.amberGold': 'const Color(0xFFFFFFFF)',
    r'AppColors\.amberGlow': 'const Color(0x30FFFFFF)',
    r'AppColors\.pinkAccent': 'const Color(0xFFFFFFFF)',
    r'AppColors\.pinkGlow': 'const Color(0x30FFFFFF)',
    r'Color\(0xFFFF3366\)': 'Color(0xFFFFFFFF)',
    r'Color\(0xFFFFD54F\)': 'Color(0xFFFFFFFF)',
    r'Color\(0xFFFFE082\)': 'Color(0xFFF2F4F6)',
    r'Color\(0xFFFFC72C\)': 'Color(0xFFE1E5E9)',
    r'Color\(0xFFFFB300\)': 'Color(0xFFFFFFFF)',
    r'Color\(0xFFD49200\)': 'Color(0xFFAAAAAA)'
}

modified_files = 0

for root, _, files in os.walk(dir_path):
    for filename in files:
        if filename.endswith('.dart'):
            filepath = os.path.join(root, filename)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            new_content = content
            for old, new in replacements.items():
                new_content = re.sub(old, new, new_content)
                
            if new_content != content:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                modified_files += 1
                print(f"Updated {filename}")

print(f"Total files updated: {modified_files}")
