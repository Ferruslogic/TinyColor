## Pintando con TinyColor

TinyColor funciona al igual que pintar sobre un lienzo. Tenemos que seleccionar un color para trabajar y envarar nuestro pincel de este color. Una vez hecho esto todo estará envarado de este color. Para envarar nuestro pincel llamamos al comando tinyColor y le pasamos el color con que queremos embarrar nuestro pincel. Este color tiene que tener un formato string.  

```objective-c
tinyColor "rgb 255 0 0"
```

En el caso anterior, envaramos nuestro pincel del color rojo. Por lo que a partir de este momento tenemos todas las operaciones que se realicen en tinyColor se realizaran con el color rojo. Exceptuando las funciones de conversión de un color a otro las cuales veremos mas adelante. No confundir con el obtener las diferentes versiones del color que estas si nos retornaran el valor equivalente para el color seleccionado en este caso el rojo.

También es valido aclarar que podemos usar la función TinyColor la cual tendrá el mismo efecto que el comando pero esta nos retornara el color en el formato que se le pasa dentro del arreglo del segundo parámetro o en RGB string si no se especifica el mismo.

```objective-c
put TinyColor( "#fff" )
```

En este caso la función retornara el RGB string y además todas las operaciones se relazarán sobre el color pasado en el primer parámetro.

## Propiedades y transformaciones del color seleccionado

Luego de tener nuestro color embarrado 