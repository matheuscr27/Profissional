#Esse programa gerarah uma senha aleatoria, conforme a necessidades do usuario
print('Esse programa gerarah uma senha aleatoria, conforme a necessidades do usuario\n')
import random

class senha_aleatoria():

    def __init__(self, caracteres, tamanho_senha):
        self.caracteres = caracteres
        self.tamanho_senha = tamanho_senha
    
    def senhas(self):
        senha = ''
        for numb in range(0, self.tamanho_senha):
            	senha = senha + random.choice(self.caracteres)
        return senha


tamanho = int(input("Colocar tamanho que a senha deve ter:\n"))
caract = input("Colocar os caracteres que a senha deve ter \n (sem espaço):\n")

senha = senha_aleatoria(caracteres = caract, tamanho_senha = tamanho)

print(f'''Sua nova senha eh
        {senha.senhas()}''')

        