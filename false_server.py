import asyncio
import socket

HOST = "127.0.0.1"
PORT = 9999

async def handle_req(r: asyncio.StreamReader, w: asyncio.StreamWriter):
    data = await r.readuntil("\r\n\r\n".encode())
    print(data.decode())
    w.write("HTTP/1.1 200 OK\r\n\r\n<html><body>hello</body></html>".encode())
    w.close()

async def ping_server():
    print(HOST)
    server = await asyncio.start_server(handle_req, HOST, PORT)

    async with server:
        await server.serve_forever()

if __name__ == "__main__":
    asyncio.run(ping_server())