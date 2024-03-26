from fastapi import FastAPI
import platform,os 

app = FastAPI()


@app.get("/")
async def showversion():
    hostname =  platform.uname().node
    version = " 0.109.2"
    return {"hostname": hostname, "version": version }

    