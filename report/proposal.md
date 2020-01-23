# UFC Judge Scoring Analysis

### Background

The Ultimate Fighting Championship (UFC) is the world's premier mixed martial arts (MMA) organization. Founded in 1993, the UFC is largely responsible for the growth of MMA and is now home to the world's best martial artists.

A UFC match involves two opposing fighters engaging in hand to hand combat over three round fights (five rounds for championship fights). There are three main ways a figher can win:

- **Submission** - Occurs when one opponent verbally submits or taps (e.g. rear naked choke).
- **Technical knockout (TKO)** - Occurs when the referee stops the fight because they have determined one fighter can no longer defend himself (e.g. punch to the face).
- **Judges score card** - Occurs when the fight lasts for all scheduled rounds. A panel of three judges scores the fight using a 10 point system. The fighter with more points is deemed the winner.

*Note there are several other possible ways to win including "technical decision", "disqualification", and "forfeit". However these situations are rarely occur.*

### Is the UFC Fair?

The UFC is a relatively new sport, and the rules are still evolving. One common source of controversy is the outcome of the fight when it goes to the judges' score cards. UFC personalities and fighters often take to the web after fights to complain about poor judging decisions. The Bleacher Report wrote an article in 2014 highlighting [The 10 Most Controversial Judging Decisions in UFC History](https://bleacherreport.com/articles/2072171-the-10-most-controversial-judging-decisions-in-ufc-history#slide0). UFC commentator [Joe Rogan](https://www.youtube.com/watch?v=v8FL1fm0wnw) is also outspoken about the perceived poor quality of judging.

So how do judges score a fight? The system is somewhat confusing, but here are the basics:

- Judges score each round on a "*10-Point Must System*".

- The fighter deemed to have won the round receives 10 points.

- The fighter deemed to have lost the round receives 9 points or fewer.

- The figher with the most points at the end of the fight wins.

- The [official MMA rules](http://www.abcboxing.com/wp-content/uploads/2016/08/juding_criteriascoring_rev0816.pdf) describe scoring as follows:

  > - "*A 10 –10 round in MMA is when both fighters have competed for whatever duration of time in the round and there is no difference or advantage between either fighter.*”
  > - “*A 10 –9 Round in MMA is when one combatant wins the round by a close margin.*”
  > - ""*A 10 –8 Round in MMA is when one fighter wins the round by a large margin.*"

- The official rules also provide additional guidance on what constitutes winning. Some examples include:

  > - "*Effective Striking/Grappling shall be considered the first priority of round assessments. Effective Aggressiveness is a ‘Plan B’ and should not be considered unless the judge does not see ANY advantage in the Effective Striking/Grappling realm. Cage/Ring Control (‘Plan C’) should only be needed when ALL other criteria are 100% even for both competitors. This will be an extremely rare occurrence.*"
  > - "*Legal blows that have immediate or cumulative impact with the potential to contribute towards the end of the match with the IMMEDIATE weighing in more heavily than the cumulative impact.*"

Based on a reading of the rules and general consensus from MMA personalities, it is clear that judging is very subjective. This analysis seeks to understand whether the judging is fair.

### Research Question

The goal of the analysis is to assess whether the judging in the UFC is consistent with the official rules and guidance. To answer this broad question, a more specific research question has been identified:

> **For fights that do not end in submission or TKO, what are the strongest predictors of who will win?**

This is a predictive question.

Some natural questions that stem from the main research question are:

- Do judges award higher scores for striking (e.g. punching and kicking) over grappling (e.g. wrestling and submission attempts)?
- Do judges consistently value the same criteria?
- Do judges consider other factors such as the fighters win streak or size?

By answering the stated research question insights into the fairness of UFC judging will be gleaned. Some possible outcomes of the analysis could be:

1. Several predictors were identified as strongly correlated to victory by decision. The judges consistently award a fighter for performing well in these areas. This would suggest that UFC judging is fair.

   > Example:
   >
   > Fighters who landed 75% more head strikes than their opponents had a 95% chance of being victorious.

2. No strong predictors were identified. The judges do no consistently score fights based on the available predictors. This would suggest that UFC judging is not fair.

   > Example:
   >
   > Fighters who landed 75% more head strikes than their opponents had a 50% chance of being victorious.

### Proposed Data Analysis Plan

There are three major decisions to make:

1. Model selection
2. Data pre-processing/feature selection
3. How to assess fairness

#### 1. Model selection

To assess the fairness of UFC judging an interpretable prediction model will be built. Multiple models with optimized hyper-parameters will be tested as part of the model selection process. 

The selected model should provide the weighs of different features. The goal of the model is to determine the weighs of the features contributing to win a fight and whether the weighing of these features is consistent with the UFC rules and guidance. 

For example, a random forest classifier may be able to achieve high accuracy, but will not provide insight into the weighing of the features and thus we can not evaluate the consistency of judging with the UFC rules and guidance.

Potential models that may be used include:

- Logistic regression
- Support vector machines
- Naive Bayes classifier

#### 2. Data pre-processing/feature selection

The downloaded data includes 144 possible features. Since the goal of the model is to predict the fight outcomes based on the performance, only features that are indictive of current fight performance will be used. The features which are not applicable will be dropped.

For example, a fighter winning or losing streak is likely predictive of the fight outcome. However when judging a fight a judge is only considering the fighters' performance during the fight.

#### 3. How to assess fairness

For purposes of this research a definition for fairness must be established. The judging of a fight should be considered fair if:

- The weighs of the features are consistent with the UFC rules and guidance
- Fights with similar characterstics result in the same outcome
- The same behaviors are consistently awarded

If it is possible to create an interpretable model that can predict with 95% or greater accuracy the judging will be considered fair. If it is not possible to acheive 95% accuracy then the judging will be deemed unfair and different judges may have different scoring criteria.

### Outcome of Analysis

This analysis may help the UFC and other governing bodies assess the quality of their judges. The end product of this analysis will be a small report including:

- A summary of the model and top weighted predictors
- Scatter plots visualizing the relationships between the most interesting predictive variables and the response
- A confusion matrix summarizing the results of predictions

## Reference

#### Useful Articles

- MMA judging criteria: http://www.abcboxing.com/wp-content/uploads/2016/08/juding_criteriascoring_rev0816.pdf
- MMA training criteria: http://www.abcboxing.com/MMA_REFEREE_AND_JUDGE_TRAINING_OUTLINE.pdf
- MMA "fouls": http://www.abcboxing.com/wp-content/uploads/2015/09/unified_rules_fouls_rev0816.pdf

#### Data

- The original data was obtained from Kaggle user [Rajeev Warrier](https://www.kaggle.com/rajeevw). 
- The data has also been downloaded and uploaded to a [GitHub repo](https://github.com/SamEdwardes/ufc-data) to avoid issues for users who do not have kaggle accounts.
