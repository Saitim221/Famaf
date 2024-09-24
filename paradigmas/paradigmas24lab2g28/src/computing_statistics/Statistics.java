package computing_statistics;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import namedEntities.NamedEntity;
import java.util.HashMap;
import java.util.HashSet;
import utils.Config;

public class Statistics {
    private static HashMap<String, Integer> ocurrences = new HashMap<String, Integer>();
    private static String type;

    public static void get_and_print_stats(List<NamedEntity> entities, String format) {
        type=format;
        if(format==null){
            type="cat";
        }
        HashSet<String> format_list = searcher(entities);
        System.out.println("-".repeat(80));
        for (String data : format_list) {
            System.out.println();
            switch(type) {
                case "cat":
                    System.out.println("Category: " + data);
                    break;
                case "topic":
                    System.out.println("Topic: " + data);
                    break;
                default:
                    break;
            }
            print(data, entities);
            ocurrences.clear();
        }
    }

    private static HashSet<String> searcher(List<NamedEntity> entities) {
        HashSet<String> format_list = new HashSet<String>();
        for (int i = 0; i < entities.size(); i++) {
            switch (type) {
                case "cat":
                    format_list.add(entities.get(i).getCategory());
                    break;
                case "topic":
                    for(int j=0; j<entities.get(i).getTopic().size(); j++){
                        format_list.add(entities.get(i).getTopic().get(j));
                    }
                    break;
                default:
                    System.out.println("Invalid stats format");
                    System.out.println("Available formats are: ");
                    System.out.println("    -cat: Category-wise");
                    System.out.println("    -topic: Topic-wise");
                    System.exit(0);
                    break;
            }
        }
        return format_list;
    }

    private static void print(String data, List<NamedEntity> analysis) {
        for(NamedEntity entity : analysis) {
            List<String> aux=new ArrayList<String>();
            switch(type){
                case "cat":
                    aux.add(entity.getCategory());
                    break;
                case "topic":
                    for(int j=0; j<entity.getTopic().size(); j++){
                        aux.add(entity.getTopic().get(j));
                    }
                    break;
                default:
                    break;
            }
            for (String aux_data : aux) {
                if (Objects.equals(aux_data, data)) {
                    if (ocurrences.containsKey(entity.getEntity())) {
                        ocurrences.put(entity.getEntity() , ocurrences.get(entity.getEntity()) + 1);
                    } else {
                        ocurrences.put(entity.getEntity() , 1);
                    }
                }
            }
        }
        for (String entity : ocurrences.keySet()) {
            System.out.println(entity + "(" + ocurrences.get(entity) + ")");
        }
    }

}