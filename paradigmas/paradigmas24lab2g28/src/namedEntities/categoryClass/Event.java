package namedEntities.categoryClass;
import namedEntities.NamedEntity;
import java.io.IOException;

public class Event extends NamedEntity {
    private String date;

    public Event(String event) throws IOException {
        super(event);
        this.date = getDate();
    }

    private String getDate() {
        // AQUI IRIA LA FORMA DE OBTENER LA FECHA DEL EVENTO
        // SUPONEMOS QUE LA FECHA DEL EVENTO DEBERIA IR EN EL DICTIONARY.JSON
        // PODRIA HABER OTRAS FORMAS DE SACAR LA FECHA DEL EVENTO
        return "18 de diciembre de 2022";
    }

    @Override
    public void print() {
        super.print();
        System.out.println("Date: " + date);
    }
}