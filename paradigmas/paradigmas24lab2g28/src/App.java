

import computing_statistics.Statistics;
import feed.Article;
import feed.FeedParser;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import namedEntities.NamedEntity;
import utils.Config;
import utils.FeedsData;
import utils.JSONParser;
import utils.UserInterface;
import namedEntities.heuristics.Heuristics;

public class App {

    public static void main(String[] args) throws IOException {

        List<FeedsData> feedsDataArray = new ArrayList<>();

        try {
            //te devuelve una lista de feeds data el cual tiene en cada elemento tiene su respectivo label, type y url.
            feedsDataArray = JSONParser.parseJsonFeedsData("src/data/feeds.json");
        } catch (IOException e) {

            e.printStackTrace();
            System.exit(1);
        }

        UserInterface ui = new UserInterface();
        Config config = ui.handleInput(args);

        run(config, feedsDataArray);

    }

//RUN
////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Change the signature of this function if needed
    private static void run(Config config, List<FeedsData> feedsDataArray) throws IOException {
        
        

        UserInterface ui = new UserInterface();
        
        if (config.getPrintHelp()) {
            ui.printHelp(feedsDataArray);
            return;
        }

        //si no hay nada devuelve "No feeds data found"
        //-f
        List<FeedsData> filteredFeedsDataArray = new ArrayList<>();
        if (config.getFeedKey() != null) {
            for (FeedsData feedData : feedsDataArray) {
                if (feedData.getLabel().equals(config.getFeedKey())) {
                    filteredFeedsDataArray.add(feedData);
                }
            }
        } else {
            filteredFeedsDataArray = feedsDataArray;
        }
        if (filteredFeedsDataArray == null || filteredFeedsDataArray.size() == 0) {
            System.out.println("No feeds data found, with -h you can see the available feeds.");
            System.exit(1);
        }

        List<Article> allArticles = new ArrayList<>();
        // HECHO: Populate allArticles with articles from corresponding feeds
        //aqui filtramos los feeds
        for (FeedsData feedData : filteredFeedsDataArray) {
            try {
                String xmlData = FeedParser.fetchFeed(feedData.getUrl());
                List<Article> articles = FeedParser.parseXML(xmlData);
                allArticles.addAll(articles);
            } catch (Exception e) {
                System.out.println("Error fetching or parsing feed: " + e.getMessage());
            }
        }

//print´s
//////////////////////////////////////////////////////////////////////////////////////////////////
        
        //-pf
        if (config.getPrintFeed() || !config.getComputeNamedEntities()) {
            System.out.println("Printing feed(s) ");
            for (Article x : allArticles) {
                x.printArticle();
                System.out.println();
            }
            // HECHO: Print the fetched feed
        }
        
        //-ne
        //creamos el string a manejar
        if (config.getComputeNamedEntities() ) {
            System.out.println(config.getNameEntityKey());
            // una vez que se tiene el texto de todos los articulos se juntan en un solo string
            String text = "";
            for (Article x : allArticles) {
                text = "" + text + " " + x.getDescription() + " " + x.getTitle() + " ";
            }

            //luego utilizamos la heuristica 
            if (config.getNameEntityKey() != null) {

                System.out.println("Computing named entities using " + config.getNameEntityKey());
                
                //cuando llamamos listEntities nos devuelve una lista de entidades con la heuristica indicada
                Heuristics heuristic = new Heuristics();
                List<String> candidates = heuristic.DoHeuristic(text, config.getNameEntityKey());
                List<NamedEntity> entities = computeEntities(candidates);
                //-sf
                //imprimimos dependiendo el sf, si no es valido devolvemos error
                Statistics statistics = new Statistics();
                statistics.get_and_print_stats(entities, config.getStatsFormatKey());              
            } 
            else {
                System.out.println("Invalid heuristic name");
                System.out.println("Available heuristic names are: ");
                System.out.println("    -CapitalizedWord");
                System.out.println("    -AfterPoint");
                System.out.println("    -TwoTimes");
                System.exit(1);
            }

        } 
        return;
    }
    private static List<NamedEntity> computeEntities(List<String> candidates) throws IOException{
        List<NamedEntity> entities = new ArrayList<>();
        for (int i = 0; i < candidates.size(); i++) {
            NamedEntity entity = new NamedEntity(candidates.get(i));
            entities.add(entity);
        }
        return entities;
    }


}
