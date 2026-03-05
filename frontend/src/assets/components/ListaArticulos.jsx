import { useEffect, useState } from "react";
import { getArticulos } from "../services/api";

export default function ListaArticulos() {
  const [articulos, setArticulos] = useState([]);
  const [error, setError] = useState(null);

  useEffect(() => {
    getArticulos()
      .then(setArticulos)
      .catch((err) => setError(err.message));
  }, []);

  if (error) return <p className="text-danger text-center">{error}</p>;

  return (
    <div className="row mt-4">
      {articulos.map((a) => (
        <div key={a.id} className="col-md-4 mb-4">
          <div className="card h-100 shadow-sm">
            <img src={a.foto} className="card-img-top" alt={a.nombre} />
            <div className="card-body">
              <h5 className="card-title">{a.nombre}</h5>
              <p className="card-text">{a.descripcion}</p>
              <div className="d-flex justify-content-between align-items-center">
                <span className="fw-bold text-primary">{a.precio} €</span>
                <span>{"⭐".repeat(a.valoracion)}</span>
              </div>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}
