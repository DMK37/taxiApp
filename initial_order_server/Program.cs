using System.Collections.Concurrent;
using System.Net;
using System.Net.WebSockets;
using System.Text;
using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);
builder.WebHost.UseUrls("http://localhost:5000");
var app = builder.Build();
app.UseWebSockets();

ConcurrentDictionary<string, WebSocket> Connections = new ConcurrentDictionary<string, WebSocket>();

app.Map("/ws", async context =>
{
    if (context.WebSockets.IsWebSocketRequest)
    {
        using var webSocket = await context.WebSockets.AcceptWebSocketAsync();

        await HandleWebSocketAsync(webSocket);
    }
    else
    {
        context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
    }
});
await app.RunAsync();

async Task HandleWebSocketAsync(WebSocket webSocket)
{
    var buffer = new byte[1024];
    while (webSocket.State == WebSocketState.Open)
    {
        var result = await webSocket.ReceiveAsync(new ArraySegment<byte>(buffer), CancellationToken.None);

        if (result.MessageType == WebSocketMessageType.Close)
        {

            Console.WriteLine("Closing WebSocket connection...");
            await webSocket.CloseAsync(WebSocketCloseStatus.NormalClosure, "Closing", CancellationToken.None);
        }
        else
        {
            var message = Encoding.UTF8.GetString(buffer, 0, result.Count);
            Console.WriteLine("Received: " + message);

            try
            {
                var jsonDocument = JsonDocument.Parse(message);
                if (jsonDocument.RootElement.TryGetProperty("action", out var actionElement))
                {
                    var action = actionElement.GetString();

                    string responseMessage;
                    if (action == "Accept")
                    {
                        responseMessage = "Action Accepted";
                    }
                    else if (action == "Reject")
                    {
                        responseMessage = "Action Rejected";
                    }
                    else
                    {
                        responseMessage = "Unknown Action";
                    }

                    var response = Encoding.UTF8.GetBytes(responseMessage);
                    await webSocket.SendAsync(new ArraySegment<byte>(response), WebSocketMessageType.Text, true,
                        CancellationToken.None);
                }
            }
            catch (JsonException)
            {
                var errorMessage = Encoding.UTF8.GetBytes("Invalid JSON format");
                await webSocket.SendAsync(new ArraySegment<byte>(errorMessage), WebSocketMessageType.Text, true,
                    CancellationToken.None);
            }
        }
    }
}