package namedEntities.categoryClass;
import namedEntities.NamedEntity;
import java.io.IOException;

public class Organization extends NamedEntity {
    private String foundationDate;

    public Organization(String organization) throws IOException {
        super(organization);
        this.foundationDate = getFoundationDate();
    }

    private String getFoundationDate() {
        // AQUI IRIA LA FORMA DE OBTENER LA FECHA DE FUNDACION DE LA ORGANIZACION
        // SUPONEMOS QUE LA FECHA DE FUNDACION DEBERIA IR EN EL DICTIONARY.JSON
        // PODRIA HABER OTRAS FORMAS DE SACAR LA FECHA DE FUNDACION
        return "12 de octubre de 1492";
    }

    @Override
    public void print() {
        super.print();
        System.out.println("Foundation Date: " + foundationDate);
    }
}