import os

files = [
    r'C:\MyProjects\snapbeat_flutter\lib\ui\screens\home_screen.dart',
    r'C:\MyProjects\snapbeat_flutter\lib\models\models.dart',
    r'C:\MyProjects\snapbeat_flutter\lib\ui\components\pro_controls_card.dart',
    r'C:\MyProjects\snapbeat_flutter\lib\ui\components\privacy_policy_dialog.dart'
]

for fpath in files:
    if os.path.exists(fpath):
        with open(fpath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # We know emoji ranges. In python, emojis are mostly > U+2600.
        # But we need to keep standard characters like bullets (• U+2022) or quotes.
        # Let's remove anything with ord() > 0x2600 (mostly emojis/symbols).
        res = []
        for ch in content:
            if ord(ch) >= 0x2600 and ord(ch) <= 0x1F9FF: # Emoji range
                continue
            res.append(ch)
            
        new_content = ''.join(res)
        with open(fpath, 'w', encoding='utf-8') as f:
            f.write(new_content)
