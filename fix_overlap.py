import os
from pathlib import Path

xml_path = Path(r"C:\MyProjects\SnapBeat\app\src\main\res\layout\activity_main.xml")
content = xml_path.read_text(encoding="utf-8")

# Fix btnSelectMusic overlapping proModeContainer
target_str = """        <androidx.appcompat.widget.AppCompatButton
            android:id="@+id/btnSelectMusic"
            android:layout_width="0dp"
            android:layout_height="75dp"
            android:layout_marginTop="40dp"
            android:background="@drawable/btn_retro_pink"
            android:text="PICK A TAPE"
            android:textSize="20sp"
            android:textStyle="bold"
            android:textColor="#FFFFFF"
            android:fontFamily="sans-serif-black"
            android:stateListAnimator="@null"
            app:layout_constraintEnd_toEndOf="parent"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintTop_toBottomOf="@+id/tvSubtitle" />"""

new_str = target_str.replace('app:layout_constraintTop_toBottomOf="@+id/tvSubtitle"', 'app:layout_constraintTop_toBottomOf="@+id/proModeContainer"')

if target_str in content:
    content = content.replace(target_str, new_str)
    xml_path.write_text(content, encoding="utf-8")
    print("Fixed btnSelectMusic constraint!")
else:
    print("Could not find the target string for btnSelectMusic")

