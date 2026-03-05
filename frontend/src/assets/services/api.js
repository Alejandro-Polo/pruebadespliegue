const API_URL = "http://localhost:8000/api/articulos";

export async function getArticulos() {
  const response = await fetch(API_URL);
  if (!response.ok) throw new Error("Error al obtener los artículos");
  return await response.json();
}