
using app2.Data;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

// agregar
// instalar el paquete Swashbuckle.AspNetCore
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();


builder.Services.AddCors(options =>
{
    options.AddPolicy("PermitirFlutter",
        policy =>
        {
            policy.AllowAnyOrigin()
                  .AllowAnyHeader()
                  .AllowAnyMethod();
        });
});

// Conextion a SQL Server
builder.Services.AddDbContext<AppDbContext>(
    options =>
       options.UseSqlServer(
           builder.Configuration.GetConnectionString("testConnection"),
           sqlServerOptionsAction: sqlOptions => {
               sqlOptions.CommandTimeout(120); // Aumenta el tiempo de espera a 2 minutos
           })
    );



var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    // agregar
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseSwagger();
app.UseSwaggerUI();

app.UseCors("PermitirFlutter");


app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
