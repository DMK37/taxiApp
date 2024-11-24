using Google.Cloud.Firestore;
using TaxiServer.Abstractions;
using TaxiServer.Data;
using TaxiServer.Services;

var builder = WebApplication.CreateBuilder(args);

string credentialsPath = Path.Combine(AppContext.BaseDirectory, 
    "taxiapp-6761d-firebase-adminsdk-4yxbd-536043c9c8.json");
Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", credentialsPath);

// Add services to the container.
builder.Services.AddSingleton<IFirestoreService>(s => 
    new FirestoreService(FirestoreDb.Create("taxiapp-6761d")));

builder.Services.AddSingleton<IClientRepository>(s =>
{
    var firestoreService = s.GetRequiredService<IFirestoreService>();
    return new ClientRepository(firestoreService);
});

builder.Services.AddSingleton<IDriverRepository>(s =>
{
    var firestoreService = s.GetRequiredService<IFirestoreService>();
    return new DriverRepository(firestoreService);
});

builder.Services.AddSingleton<IPricingService>(s => new PricingService());

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo
    {
        Title = "Taxi App API",
        Version = "v1",
        Description = "API documentation for the Taxi app, showcasing available endpoints and their usage."
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment() || app.Environment.IsStaging())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
