package grupo39.namedEntities;

import java.io.IOException;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

import grupo39.utils.DictionaryData;
import grupo39.utils.JSONParser;

public class NamedEntity implements Serializable {
    private String entity;
    private String category;
    private List<String> topic;
    private String characteristic;

    public NamedEntity(String candidate,List<DictionaryData> dict ) throws IOException {
        this.entity = candidate;
        JSONParser parser = new JSONParser();
        //List<DictionaryData> dictionarylist = parser.parseJsonDictionaryData("../../Documentos/2024/Paradigmas/lab2/paradigmas24lab2g28/src/main/java/grupo39/data/dictionary.json"); 
        List<DictionaryData> dictionarylist = dict;
        if (!recognitionAndSetup(candidate, dictionarylist)) {
            this.category = "OTHER";
            this.topic = new ArrayList<>();
            this.topic.add("OTHER");
            getCharacteristic();
        }
            
    }

    private boolean recognitionAndSetup(String candidate, List<DictionaryData> dictionarylist) {
        boolean recognizable = false;

        for (DictionaryData dictionaryData : dictionarylist) {
            for (String keyword : dictionaryData.getKeywords()) {
                if (Objects.equals(keyword, candidate)) {
                    recognizable = true;
                    this.category = dictionaryData.getCategory();
                    this.topic = List.copyOf(dictionaryData.getTopics());
                    this.entity = dictionaryData.getLabel();
                    
                }
            }
        }

        return recognizable;
    }

    public String getEntity() {
        return entity;
    }

    public String getCategory() {
        return category;
    }

    public List<String> getTopic() {
        return topic;
    }

    public void print() {
        System.out.println("Entity: " + entity);
        System.out.println("Category: " + category);
        System.out.println("Topic: " + topic);
        System.out.println("Characteristic: " + characteristic);
    }

    private void getCharacteristic() {
        // AQUI IRIA LA FORMA DE OBTENER LA CARACTERISTICAS DE LA ENTIDAD
        // SUPONEMOS QUE LA CARACTERISTICA DEBERIA IR EN EL DICTIONARY.JSON
        // PODRIA HABER OTRAS FORMAS DE SACAR LA CARACTERISTICA, PRINCIPALMENTE DEPENDIENDO DE LA CATEGORIA
        // PROBLEMA QUE NO RESOLVEREMOS
        // ES POSIBLE QUE VARIANDO LA CATEGORIA, SE OBTENGAN CARACTERISTICAS DE DIFERENTES FORMAS
        // PARA ELLO DEBERIAMOS HACER UN SWITCH
        switch (this.category) {
            case "PERSON":
                this.characteristic = "MY_AGE";
                break;
            case "LOCATION":
                this.characteristic = "MY_LONGITUD_Y_LATITUD";
                break;
            case "ORGANIZATION":
                this.characteristic = "MY_NUMBER_OF_WORKERS";
                break;
            case "EVENT":
                this.characteristic = "MY_YEAR";
                break;
            default:
                this.characteristic = "MY_CHARACTERISTIC";
        }
    }
    

}




