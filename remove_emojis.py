import os
import re

files = [
    r'C:\MyProjects\snapbeat_flutter\lib\ui\screens\home_screen.dart',
    r'C:\MyProjects\snapbeat_flutter\lib\models\models.dart',
    r'C:\MyProjects\snapbeat_flutter\lib\ui\components\pro_controls_card.dart',
    r'C:\MyProjects\snapbeat_flutter\lib\ui\components\privacy_policy_dialog.dart'
]

def clean_emojis(text):
    # This covers many emojis
    return re.sub(r'[^\x00-\x7F]+', lambda m: '' if len(m.group(0)) == 1 and ord(m.group(0)) > 8000 else m.group(0), text)

for fpath in files:
    if os.path.exists(fpath):
        with open(fpath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Manually clear out emojis, keeping standard unicode like bullets (• is 8226, let's keep things carefully)
        # Actually it's easier to just strip them by explicit list if we know them
        emojis = ['⚡', '🎬', '✨', '🚀', '🔥', '💎', '🎵', '📸', '⚙️', '🌟', '⏱️', '🎞️', '👑', '🎉', '🎧', '👉']
        for e in emojis:
            content = content.replace(e, '')
            
        with open(fpath, 'w', encoding='utf-8') as f:
            f.write(content)
