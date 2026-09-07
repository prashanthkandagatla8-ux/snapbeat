import os
import uvicorn
from gateway import app

if __name__ == "__main__":
    port = int(os.environ.get("PORT", os.environ.get("SNAPBEAT_GATEWAY_PORT", "8000")))
    uvicorn.run("gateway:app", host="0.0.0.0", port=port, reload=True)
