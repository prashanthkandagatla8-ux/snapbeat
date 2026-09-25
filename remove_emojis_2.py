import re

files = [
    r'lib/ui/screens/home_screen.dart',
    r'lib/models/models.dart',
    r'lib/ui/components/pro_controls_card.dart',
    r'lib/ui/components/privacy_policy_dialog.dart'
]

emojis = ['🔒', '✨', '🔥', '📸', '🎵', '🎶', '🔊', '🤫', '🌟', '⚠️', '✅', '❌', '🚀', '💡', '💬', '👇']

for filepath in files:
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        for e in emojis:
            content = content.replace(e, '')
            
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Cleaned {filepath}")
    except Exception as e:
        print(f"Error on {filepath}: {e}")
