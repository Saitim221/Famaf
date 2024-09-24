package grupo39;

import java.io.IOException;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.sql.SparkSession;

import grupo39.computing_statics.Stadistics;
import grupo39.namedEntities.NamedEntity;
import grupo39.namedEntities.heuristics.Heuristics;
import grupo39.utils.DictionaryData;
import grupo39.utils.JSONParser;


public final class App implements Serializable{

  //private static final Pattern SPACE = Pattern.compile(" ");

    public static void main(String[] args) throws IOException {
        
        if (args.length < 2) {

            System.err.println("Usage: <file> <dictionary> ");
            System.exit(1);

        }
        // El segundo argumento es el path del diccionario
        String dictionaryPath = args[1];

        SparkSession spark = SparkSession
        .builder()
        .appName("Named entities")
        .getOrCreate();

        JavaRDD<String> lines = spark.read().textFile(args[0]).javaRDD();
    
        

        //System.out.println(" por hacer heuristicas");        
        JavaRDD<List<String>> candidates = lines.map(s->{
            Heuristics heuristic = new Heuristics();
            return heuristic.DoHeuristic(s, "CapitalizedWord");
        });
        JavaRDD<List<NamedEntity>> entities = candidates.map(s-> computeNamedEntities(s, new JSONParser().parseJsonDictionaryData(dictionaryPath))); 
        
        System.out.println("named entities hechos, por juntar en una sola lista");
        JavaRDD<NamedEntity> entitiesaux = entities.flatMap(s -> s.iterator());
    
        try {
            JavaRDD<NamedEntity> noOther = entitiesaux.filter(s -> !s.getCategory().equals("OTHER"));
            System.out.println("lista hecha, por juntar todo");
                            
            List<NamedEntity> entitiesList = noOther.collect();

            System.out.println("todo hecho, por hacer estadisticas");
            Stadistics stadistics = new Stadistics();
            stadistics.get_and_print_stats(entitiesList, "cat"); 
                     
            spark.stop();
        } catch (Exception e) {
            System.err.println("An error occurred: " + e.getMessage());
            e.printStackTrace();
        }

    }

    
    private static List<NamedEntity> computeNamedEntities (List<String> candidates,List<DictionaryData> dict) throws IOException{
        List<NamedEntity> entities = new ArrayList<>();
        for (int i = 0; i < candidates.size(); i++) {
            NamedEntity entity = new NamedEntity(candidates.get(i), dict);
            entities.add(entity);
        }
        return entities;
    }

}


