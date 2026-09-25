import os
import re

replacements = {
    r'AppColors\.primaryBackgroundDark': 'AppColors.primarySurface',
    r'AppColors\.textFoilGold': 'AppColors.accent',
    r'AppColors\.brassHighlight': 'AppColors.accent',
    r'AppColors\.canvasChassis': 'AppColors.primaryBackground',
    r'AppColors\.grooveLight': 'AppColors.border',
    r'AppColors\.grooveDark': 'AppColors.secondarySurface',
    r'AppColors\.textWhiteSecondary': 'AppColors.secondaryText',
    r'AppColors\.borderBrass': 'AppColors.border',
    r'AppColors\.pinkAccent': 'AppColors.accent',
    r'AppColors\.metalHighlight': 'AppColors.secondarySurface',
    r'AppColors\.borderSubtle': 'AppColors.border',
    r'AppColors\.textInkTertiary': 'AppColors.secondaryText',
    r'AppColors\.darkHardwareShadow': 'AppColors.softShadow',
}

def replace_in_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        original = content
        for old, new in replacements.items():
            content = re.sub(old, new, content)
            
        if content != original:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Updated {filepath}")
    except Exception as e:
        print(f"Failed to process {filepath}: {e}")

target_dir = r'C:\MyProjects\snapbeat_flutter'
for root, _, files in os.walk(target_dir):
    for file in files:
        if file.endswith('.dart'):
            replace_in_file(os.path.join(root, file))
