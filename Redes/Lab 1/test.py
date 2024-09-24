import requests

# Obtener todas las películas
response = requests.get('http://localhost:5000/peliculas')
peliculas = response.json()
print("Películas existentes:")
for pelicula in peliculas:
    print(f"ID: {pelicula['id']}, Título: {pelicula['titulo']}, Género: {pelicula['genero']}")
print()

# Agregar una nueva película
nueva_pelicula = {
    'titulo': 'Pelicula de prueba',
    'genero': 'Acción'
}
response = requests.post('http://localhost:5000/peliculas', json=nueva_pelicula)
if response.status_code == 201:
    pelicula_agregada = response.json()
    print("Película agregada:")
    print(f"ID: {pelicula_agregada['id']}, Título: {pelicula_agregada['titulo']}, Género: {pelicula_agregada['genero']}")
else:
    print("Error al agregar la película.")
print()

# Obtener detalles de una película específica
id_pelicula = 1  # ID de la película a obtener
response = requests.get(f'http://localhost:5000/peliculas/{id_pelicula}')
if response.status_code == 200:
    pelicula = response.json()
    print("Detalles de la película:")
    print(f"ID: {pelicula['id']}, Título: {pelicula['titulo']}, Género: {pelicula['genero']}")
else:
    print("Error al obtener los detalles de la película.")
print()

# Actualizar los detalles de una película
id_pelicula = 1  # ID de la película a actualizar
datos_actualizados = {
    'titulo': 'Nuevo título',
    'genero': 'Comedia'
}
response = requests.put(f'http://localhost:5000/peliculas/{id_pelicula}', json=datos_actualizados)
if response.status_code == 200:
    pelicula_actualizada = response.json()
    print("Película actualizada:")
    print(f"ID: {pelicula_actualizada['id']}, Título: {pelicula_actualizada['titulo']}, Género: {pelicula_actualizada['genero']}")
else:
    print("Error al actualizar la película.")
print()

# Eliminar una película
id_pelicula = 1  # ID de la película a eliminar
response = requests.delete(f'http://localhost:5000/peliculas/{id_pelicula}')
if response.status_code == 200:
    print("Película eliminada correctamente.\n")
else:
    print("Error al eliminar la película.\n")

#Buscar por nombre
    
nombre = "I"
response = requests.get(f'http://localhost:5000/peliculas/{nombre}')
if response.status_code == 200:
    print("Se proporcionara una lista de peliculas basada en el nombre dado correctamente.")
    lista_de_peliculas = response.json()
    print(f"{lista_de_peliculas}\n")
   
else:
    print("Error al buscar la película.")


#Obtener todas las peliculas de un mismo genero
    
genero = "Drama"
response = requests.get(f'http://localhost:5000/peliculas/genero/{genero}')
if response.status_code == 200:
    print("Se va a dar una lista de peliculas del genero dado exitosamente")
    lista_de_peliculas = response.json()
    print(f"{lista_de_peliculas}\n")
    
else:
    print("Error al buscar las películas.")

#Obtener una pelicula aleatoria

response = requests.get('http://localhost:5000/peliculas/random') 
if response.status_code == 200:
    print("Se va proporcinar una pelicula aleatoria exitosamente")
    peli_random = response.json() 
    print(f"{peli_random}\n")
    
else:
    print("Error al mandar pelicula")

#Obtener una pelicula aleatoria basada en un genero
response = requests.get(f'http://localhost:5000/peliculas/random/{genero}')
if response.status_code == 200:
    print("Se va a proporcinar una pelicula aleatoria basada en un genero exitosamente")
    peli_random = response.json() 
    print(f"{peli_random}\n")
    
else:
    print("Error al mandar pelicula")

#Obtener una sugerencia de pelicula para el proximo dia feriado
response = requests.get(f'http://localhost:5000/peliculas/sugerencia/{genero}')
if response.status_code == 200:
    print("Se va a proporcinar una pelicula con una fecha de feriado  exitosamente")
    peli_random_mas_fecha = response.json() 
    print(f"{peli_random_mas_fecha}\n")
    
else:
    print("Error al mandar pelicula")
