package grupo39.utils;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class UserInterface {

    private HashMap<String, String> optionDict;
    private List<Option> options;

    public UserInterface() {
        options = new ArrayList<>();
        options.add(new Option("-h", "--help", 0));
        options.add(new Option("-f", "--feed", 1));
        options.add(new Option("-ne", "--named-entity", 1));
        options.add(new Option("-pf", "--print-feed", 0));
        options.add(new Option("-sf", "--stats-format", 1));

        optionDict = new HashMap<>();
    }

    public Config handleInput(String[] args) {
        for (int i = 0; i < args.length; i++) {
            boolean exists = false;
            for (Option option : options) {
                if (option.getName().equals(args[i]) || option.getLongName().equals(args[i])) {
                    exists = true;
                    if (option.getnumValues() == 0) {
                        if(i + 1 < args.length && !args[i + 1].startsWith("-")) {
                            System.out.println("Invalid numbers of arguments for " + option.getName() + " option");
                            System.out.println(option.getName() + " option does not require any arguments");
                            System.exit(1);
                        }
                        optionDict.put(option.getName(), null);
                    } else {
                        if (i + 1 < args.length && !args[i + 1].startsWith("-")) {
                            optionDict.put(option.getName(), args[i + 1]);
                            i++;
                        } else if (option.getName().equals("-ne")) {
                            System.out.println("Invalid numbers of arguments for -ne option");
                            System.out.println("You have to add exactly one argument for -ne option");
                            System.out.println("Use -h option to see the available -ne arguments");
                            System.exit(1);
                        } else if (option.getName().equals("-f")) {
                            System.out.println("You have to chose a feed key");
                            System.out.println("Use -h option to see the available feed keys");
                            System.exit(1);
                        } else if (option.getName().equals("-sf")) {
                            optionDict.put(option.getName(), "cat");
                        } else {
                            System.out.println("Invalid numbers of arguments for " + option.getName() + " option");
                            System.exit(1);
                        }

                    }
                }
            }
            if (!exists) {
                System.out.println("Invalid option " + args[i]);
                System.exit(1);
            }
        }

        boolean printFeed = optionDict.containsKey("-pf");
        boolean printHelp = optionDict.containsKey("-h");
        boolean computeNamedEntities = optionDict.containsKey("-ne");
        // TODO: use value for heuristic config

        String feedKey = optionDict.get("-f");

        String nameEntityKey = optionDict.get("-ne");
        String statsFormatKey = optionDict.get("-sf");
        if (statsFormatKey == null) {
            statsFormatKey = "cat";
        }

        return new Config(printFeed, computeNamedEntities, printHelp, feedKey, nameEntityKey, statsFormatKey);
    }

    public void printHelp(List<FeedsData> feedsDataArray) {
        System.out.println("Usage: make run ARGS=\"[OPTION]\"");
        System.out.println("Options:");
        System.out.println("  -h, --help: Show this help message and exit");
        System.out.println("  -f, --feed <feedKey>:                Fetch and process the feed with");
        System.out.println("                                       the specified key");
        System.out.println("                                       Available feed keys are: ");
        for (FeedsData feedData : feedsDataArray) {
            System.out.println("                                       " + feedData.getLabel());
        }
        System.out.println("  -ne, --named-entity <heuristicName>: Use the specified heuristic to extract");
        System.out.println("                                       named entities");
        System.out.println("                                       Available heuristic names are: ");
        System.out.println("                                       CapitalizedWord: selects candidates if they start with uppercase letters");
        System.out.println("                                       AfterPoint: selects candidates except those followed by a period");
        System.out.println("                                       TwoTimes: checks if they appear again in lowercase");
        System.out.println("  -pf, --print-feed:                   Print the fetched feed");
        System.out.println("  -sf, --stats-format <format>:        Print the stats in the specified format");
        System.out.println("                                       Available formats are: ");
        System.out.println("                                       cat: Category-wise stats");
        System.out.println("                                       topic: Topic-wise stats");
    }
}
