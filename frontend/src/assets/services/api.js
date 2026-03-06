const API_URL = "http://tienda-react.ddns.net/api/articulos";

export async function getArticulos() {
  const response = await fetch(API_URL);
  if (!response.ok) throw new Error("Error al obtener los artículos");
  return await response.json();
}