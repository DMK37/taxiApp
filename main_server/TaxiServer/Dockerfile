FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /app

COPY . .

RUN dotnet restore
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/out .

EXPOSE 5112

ENV ASPNETCORE_URLS=http://192.168.18.81:5112


ENTRYPOINT ["dotnet", "TaxiServer.dll"]