import re
from pathlib import Path

kt_path = Path(r"C:\MyProjects\SnapBeat\app\src\main\java\com\kiro\snapbeat\MainActivity.kt")
content = kt_path.read_text(encoding="utf-8")

# Let's replace the switchMode listener and add Spinner setup.
old_listener = """        binding.switchMode.setOnCheckedChangeListener { _, isChecked ->
            if (!isChecked) {
                Toast.makeText(this, "Pro Mode coming soon!", Toast.LENGTH_SHORT).show()
                binding.switchMode.isChecked = true
            }
        }"""

new_listener = """        val templates = arrayOf("Auto (Beat Cut)", "Simple", "Pendulum")
        val adapter = android.widget.ArrayAdapter(this, android.R.layout.simple_spinner_dropdown_item, templates)
        binding.spinnerTemplate.adapter = adapter

        binding.switchMode.setOnCheckedChangeListener { _, isChecked ->
            if (isChecked) {
                binding.switchMode.text = "BASIC"
                binding.proModeContainer.visibility = android.view.View.GONE
            } else {
                binding.switchMode.text = "PRO"
                binding.proModeContainer.visibility = android.view.View.VISIBLE
            }
        }"""

if old_listener in content:
    content = content.replace(old_listener, new_listener)
else:
    print("Could not find old listener")

# Now inject the template into uploadAndRender
old_build = """                val requestBody = builder.build()
                val request = Request.Builder()"""

new_build = """                if (!binding.switchMode.isChecked) {
                    val selection = binding.spinnerTemplate.selectedItem.toString()
                    val templateName = when(selection) {
                        "Simple" -> "simple"
                        "Pendulum" -> "pendulum"
                        else -> "beat-cut"
                    }
                    builder.addFormDataPart("template", templateName)
                }

                val requestBody = builder.build()
                val request = Request.Builder()"""

if old_build in content:
    content = content.replace(old_build, new_build)
else:
    print("Could not find build logic")

kt_path.write_text(content, encoding="utf-8")
print("Patched kt!")
