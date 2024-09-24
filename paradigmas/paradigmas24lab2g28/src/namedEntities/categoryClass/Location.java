package namedEntities.categoryClass;
import namedEntities.NamedEntity;
import java.io.IOException;

public class Location extends NamedEntity {
    private String longitude;
    private String latitude;

    public Location(String location) throws IOException {
        super(location);
        this.longitude = getlongitude();
        this.latitude = getlatitude();
    }

    private String getlongitude() {
        // AQUI IRIA LA FORMA DE OBTENER LA LONGITUD DE LA LOCATION
        // SUPONEMOS QUE LA LONGITUD DEBERIA IR EN EL DICTIONARY.JSON
        // PODRIA HABER OTRAS FORMAS DE SACAR LA LONGITUD
        return "63°55'04.80' Oeste";
    }

    private String getlatitude() {
        // AQUI IRIA LA FORMA DE OBTENER LA LATITUD DE LA LOCATION
        // SUPONEMOS QUE LA LATITUD DEBERIA IR EN EL DICTIONARY.JSON
        // PODRIA HABER OTRAS FORMAS DE SACAR LA LATITUD
        return "32°18'36.00' Sur";
    }

    @Override
    public void print() {
        super.print();
        System.out.println("longitude: " + longitude);
        System.out.println("latitude: " + latitude);
    }
}