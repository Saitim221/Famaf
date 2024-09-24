# encoding: utf-8
# Revisión 2019 (a Python 3 y base64): Pablo Ventura
# Copyright 2014 Carlos Bederián
# $Id: connection.py 455 2011-05-01 00:32:09Z carlos $
import os
import os.path
import socket
from constants import *
from base64 import b64encode

class Connection(object):
    """
    Conexión punto a punto entre el servidor y un cliente.
    Se encarga de satisfacer los pedidos del cliente hasta
    que termina la conexión.
    """

    def __init__(self, socket, directory):
        # FALTA: Inicializar atributos de Connection
        
        self.socket=socket
        self.directory=directory
        self.buffer = ''
        self.connected = True
        self.status = None
        pass

    def _recv(self):
        """
        Recibe datos y acumula en el buffer interno.

        Para uso privado del cliente.
        """
        data = self.socket.recv(4096).decode("ascii")
        self.buffer += data
       
        

    def read_line(self):
        """
        Espera datos hasta obtener una línea completa delimitada por el
        terminador del protocolo.

        Devuelve la línea, eliminando el terminaodr y los espacios en blanco
        al principio y al final.
        """
        while not EOL in self.buffer and self.connected:
                self._recv()
        
                if(self.buffer.find('\n')>0 and self.buffer[self.buffer.find('\n')-1]!='\r'):    
                        self.socket.send((str(BAD_EOL)+" "+error_messages[BAD_EOL]+str(EOL)).encode("utf-8"))
                        self.connected=False
        if EOL in self.buffer:
            response, self.buffer = self.buffer.split(EOL, 1)
            return response.strip()
              
        else:
            self.connected = False
            return ""
        
    def close(self):
        """
        Desconecta al cliente del server, mandando el mensaje apropiado
        antes de desconectar.
        """ 
        self.socket.send((str(CODE_OK)+" "+error_messages[CODE_OK]+str(EOL)).encode("utf-8"))
        self.connected = False


    def get_file_listing(self):

        contenido = os.listdir(DEFAULT_DIR)
        self.socket.send((str(CODE_OK)+" "+error_messages[CODE_OK]+str(EOL)).encode("utf-8"))
        for elemento in contenido:
            elemento+=str(EOL)
            self.socket.send(elemento.encode("utf-8"))
        self.socket.send(EOL.encode("utf-8"))

    def get_metadata (self,filename):
        path=DEFAULT_DIR + "/" + filename
        if(os.path.exists(path)):
            tam=os.path.getsize(path)
            str_tam=str(tam)
            str_tam+=EOL
            self.socket.send((str(CODE_OK)+" "+error_messages[CODE_OK]+str(EOL)).encode("utf-8"))
            self.socket.send(str_tam.encode("utf-8"))
            
        else: 
            self.socket.send((str(FILE_NOT_FOUND)+" "+error_messages[FILE_NOT_FOUND]+str(EOL)).encode("utf-8"))

    def get_slice (self,filename,offset,size):
        path=DEFAULT_DIR + "/" + filename
        if(os.path.exists(path)):
            with open(path, 'r') as file:
                data = file.read()
            a = int(offset)
            b = int(size)
            if(a<len(data)):
                slice=data[a:(a+b)].encode("utf-8")
                self.socket.send((str(CODE_OK)+" "+error_messages[CODE_OK]+str(EOL)).encode("utf-8"))
                self.socket.send(b64encode(slice))
                self.socket.send(EOL.encode("utf-8"))
            else:
                self.socket.send((str(BAD_OFFSET)+" "+error_messages[BAD_OFFSET]+str(EOL)).encode("utf-8"))
        else:
            self.socket.send((str(FILE_NOT_FOUND)+" "+error_messages[FILE_NOT_FOUND]+str(EOL)).encode("utf-8"))
                
    def redirect(self,x):
        arr=x.split(" ")
        while("" in arr):
            arr.remove("")
        if(len(arr)==0):
            pass
        elif(arr[0]=="get_file_listing"):
            if(len(arr)==1):
                self.get_file_listing()
            else:
                self.socket.send((str(INVALID_ARGUMENTS)+" "+error_messages[INVALID_ARGUMENTS]+str(EOL)).encode("utf-8"))
        elif(arr[0]=="quit"):
            if(len(arr)==1):
                self.close()
            else:
                self.socket.send((str(INVALID_ARGUMENTS)+" "+error_messages[INVALID_ARGUMENTS]+str(EOL)).encode("utf-8"))
        elif(arr[0]=="get_metadata"):
            if(len(arr)==2):
                self.get_metadata(arr[1])
            else:
                self.socket.send((str(INVALID_ARGUMENTS)+" "+error_messages[INVALID_ARGUMENTS]+str(EOL)).encode("utf-8"))
        elif(arr[0]=="get_slice"):
            if(len(arr)==4):
                if(arr[2].isdigit() or arr[3].isdigit()):
                    self.get_slice(arr[1],arr[2],arr[3])
                else:
                    self.socket.send((str(INVALID_ARGUMENTS)+" "+error_messages[INVALID_ARGUMENTS]+str(EOL)).encode("utf-8"))
            else: 
                self.socket.send((str(INVALID_ARGUMENTS)+" "+error_messages[INVALID_ARGUMENTS]+str(EOL)).encode("utf-8"))
        else:
            self.socket.send((str(INVALID_COMMAND)+" "+error_messages[INVALID_COMMAND]+str(EOL)).encode("utf-8"))
             
    def handle(self):
        """
        Atiende eventos de la conexión hasta que termina.
        """
        while self.connected:
            x = self.read_line()
            self.redirect(x)
        self.socket.close()
           
           