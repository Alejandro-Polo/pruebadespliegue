<?php

namespace App\Controller;

use App\Repository\ArticuloRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/api/articulos', name: 'api_articulos_')]
class ApiArticuloController extends AbstractController
{
    #[Route('', name: 'list', methods: ['GET'])]
    public function list(ArticuloRepository $articuloRepository): JsonResponse
    {
        $articulos = $articuloRepository->findAll();

        $data = [];

        foreach ($articulos as $articulo) {
            $data[] = [
                'id' => $articulo->getId(),
                'nombre' => $articulo->getNombre(),
                'descripcion' => $articulo->getDescripcion(),
                'foto' => $articulo->getFoto(),
                'precio' => $articulo->getPrecio(),
                'valoracion' => $articulo->getValoracion(),
            ];
        }

        return $this->json($data);
    }
}
