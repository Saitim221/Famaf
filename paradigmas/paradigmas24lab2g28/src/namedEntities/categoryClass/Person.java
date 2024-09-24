package namedEntities.categoryClass;
import namedEntities.NamedEntity;
import java.io.IOException;

public class Person extends NamedEntity {
    private int age;

    public Person(String person) throws IOException {
        super(person);
        this.age = getAge();
    }

    private int getAge() {
        // AQUI IRIA LA FORMA DE OBTENER LA EDAD DE LA PERSONA
        // SUPONEMOS QUE LA EDAD DEBERIA IR EN EL DICTIONARY.JSON
        // PODRIA HABER OTRAS FORMAS DE SACAR LA EDAD
        return 20;
    }

    @Override
    public void print() {
        super.print();
        System.out.println("Age: " + age);
    }
}
