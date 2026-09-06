import re
from pathlib import Path

xml_path = Path(r"C:\MyProjects\SnapBeat\app\src\main\res\layout\activity_main.xml")
content = xml_path.read_text(encoding="utf-8")

# Add a Spinner after tvSubtitle
spinner_xml = """

        <LinearLayout
            android:id="@+id/proModeContainer"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:visibility="gone"
            android:layout_marginTop="16dp"
            app:layout_constraintTop_toBottomOf="@+id/tvSubtitle">
            
            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="PRO TEMPLATE:"
                android:textStyle="bold"
                android:textColor="#000000"
                android:fontFamily="sans-serif-black"/>
                
            <Spinner
                android:id="@+id/spinnerTemplate"
                android:layout_width="match_parent"
                android:layout_height="48dp"
                android:background="#EEEEEE"
                android:layout_marginTop="8dp"/>
        </LinearLayout>
"""
if "proModeContainer" not in content:
    content = content.replace('app:layout_constraintTop_toBottomOf="@+id/tvTitle" />', 'app:layout_constraintTop_toBottomOf="@+id/tvTitle" />' + spinner_xml)
    # Also need to adjust btnSelectMusic's top constraint
    content = content.replace('app:layout_constraintTop_toBottomOf="@+id/tvSubtitle"', 'app:layout_constraintTop_toBottomOf="@+id/proModeContainer"')
    xml_path.write_text(content, encoding="utf-8")
    print("Patched xml!")
else:
    print("XML already patched.")

