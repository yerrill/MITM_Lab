#!/bin/python3

import asyncio

HOST = "127.0.0.1"
PORT = 9999
PAGE = None

def matcher(data: str) -> str:
    base = "HTTP/1.1 200 OK\r\n\r\n"
    return base + PAGE

async def handle_req(r: asyncio.StreamReader, w: asyncio.StreamWriter):
    data = await r.readuntil("\r\n\r\n".encode())
    line = data.decode().split("\r\n")[0]
    print(line)
    w.write(matcher(line).encode())
    w.close()

async def ping_server():
    print(HOST)
    server = await asyncio.start_server(handle_req, HOST, PORT)

    async with server:
        await server.serve_forever()

if __name__ == "__main__":
    rf = open('AttackPage.html', 'r')
    PAGE = rf.read()
    rf.close()
    asyncio.run(ping_server())