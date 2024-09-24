from flask import Flask, jsonify, request
import random
import proximo_feriado #usa la api de proximoferiado

app = Flask(__name__)
peliculas = [
    {'id': 1, 'titulo': 'Indiana Jones', 'genero': 'Acción'},
    {'id': 2, 'titulo': 'Star Wars', 'genero': 'Acción'},
    {'id': 3, 'titulo': 'Interstellar', 'genero': 'Ciencia ficción'},
    {'id': 4, 'titulo': 'Jurassic Park', 'genero': 'Aventura'},
    {'id': 5, 'titulo': 'The Avengers', 'genero': 'Acción'},
    {'id': 6, 'titulo': 'Back to the Future', 'genero': 'Ciencia ficción'},
    {'id': 7, 'titulo': 'The Lord of the Rings', 'genero': 'Fantasía'},
    {'id': 8, 'titulo': 'The Dark Knight', 'genero': 'Acción'},
    {'id': 9, 'titulo': 'Inception', 'genero': 'Ciencia ficción'},
    {'id': 10, 'titulo': 'The Shawshank Redemption', 'genero': 'Drama'},
    {'id': 11, 'titulo': 'Pulp Fiction', 'genero': 'Crimen'},
    {'id': 12, 'titulo': 'Fight Club', 'genero': 'Drama'}
]


def obtener_peliculas():
    return jsonify(peliculas)


def obtener_pelicula(id):
    # Lógica para buscar la película por su ID y devolver sus detalles
    pelicula_encontrada=peliculas[id-1]
    return jsonify(pelicula_encontrada)


def agregar_pelicula():
    nueva_pelicula = {
        'id': obtener_nuevo_id(),
        'titulo': request.json['titulo'],
        'genero': request.json['genero']
    }
    peliculas.append(nueva_pelicula)
    print(peliculas)
    return jsonify(nueva_pelicula), 201


def actualizar_pelicula(id):
    # Lógica para buscar la película por su ID y actualizar sus detalles
    pelicula_actualizada = peliculas[id-1]
    pelicula_actualizada = {
        'id': id,
        'titulo': request.json['titulo'],
        'genero': request.json['genero']
    }
    peliculas[id-1]=pelicula_actualizada
    return jsonify(pelicula_actualizada)


def eliminar_pelicula(id):
    # Lógica para buscar la película por su ID y eliminarla
    del peliculas[id-1]
    for i in range (id,len(peliculas)):
            peliculas[i-1]['id']=i;
    return jsonify({'mensaje': 'Película eliminada correctamente'})



def obtener_nuevo_id():
    if len(peliculas) > 0:
        ultimo_id = peliculas[-1]['id']
        return ultimo_id + 1
    else:
        return 1

def buscar_por_nombre(subs):
    lista=[]
    for i in range (len(peliculas)):
        if(subs in peliculas[i]['titulo']):
            lista.append(peliculas[i])
    return jsonify(lista) 


def obtener_pelicula_genero(genero):
    genero = str(genero)
    encoded = genero.encode('utf-8')
    peliculas_genero = []
    for i in range (0,len(peliculas)):
            peliculas[i]['genero'] = str(peliculas[i]['genero'])
            pelis = peliculas[i]['genero'].encode('utf-8')
            if pelis == encoded:
                 peliculas_genero.append(peliculas[i])
    return jsonify(peliculas_genero)

def peli_random():
    numero_random = random.randrange(0, len(peliculas))
    peli_random = peliculas[numero_random]
    return jsonify(peli_random)

def peli_random_por_genero(genero):
    peliculas_genero = []
    genero = str(genero)
    encoded = genero.encode('utf-8')
    for i in range (0,len(peliculas)):
            peliculas[i]['genero'] = str(peliculas[i]['genero'])
            pelis = peliculas[i]['genero'].encode('utf-8')
            if pelis == encoded:
                 peliculas_genero.append(peliculas[i])
    numero_random = random.randrange(0, len(peliculas_genero))
    peli_random_g = peliculas_genero[numero_random]
    return jsonify(peli_random_g)

def pelicula_feriado(genero):
    peliculas_genero = []
    genero = str(genero)
    encoded = genero.encode('utf-8')
    for i in range (0,len(peliculas)):
            peliculas[i]['genero'] = str(peliculas[i]['genero'])
            pelis = peliculas[i]['genero'].encode('utf-8')
            if pelis == encoded:
                 peliculas_genero.append(peliculas[i])
    numero_random = random.randrange(0, len(peliculas_genero))
    peli_random_g = peliculas_genero[numero_random]
    x=proximo_feriado.NextHoliday()
    x.fetch_holidays()
    y={
        'dia': x.holiday['dia'],
        'mes': x.holiday['mes'],
        'motivo': x.holiday['motivo'],
        'tipo': x.holiday['tipo'],
        'id':  peli_random_g['id'],
        'titulo': peli_random_g['titulo'],
        'genero': peli_random_g['genero']
    }

    return jsonify(y)

app.add_url_rule('/peliculas/', 'obtener_peliculas', obtener_peliculas, methods=['GET'])
app.add_url_rule('/peliculas/<int:id>', 'obtener_pelicula', obtener_pelicula, methods=['GET'])
app.add_url_rule('/peliculas/', 'agregar_pelicula', agregar_pelicula, methods=['POST'])
app.add_url_rule('/peliculas/<int:id>', 'actualizar_pelicula', actualizar_pelicula, methods=['PUT'])
app.add_url_rule('/peliculas/<int:id>', 'eliminar_pelicula', eliminar_pelicula, methods=['DELETE'])
app.add_url_rule('/peliculas/<string:subs>', 'buscar_por_nombre', buscar_por_nombre, methods=['GET'])
app.add_url_rule('/peliculas/genero/<string:genero>', 'obtener_pelicula_genero', obtener_pelicula_genero, methods=['GET'])
app.add_url_rule('/peliculas/random', 'peli_random', peli_random, methods=['GET'])
app.add_url_rule('/peliculas/random/<string:genero>', 'peli_random_por_genero', peli_random_por_genero, methods=['GET'])
app.add_url_rule('/peliculas/sugerencia/<string:genero>', 'pelicula_feriado', pelicula_feriado, methods=['GET'])
if __name__ == '__main__':
    app.run()
