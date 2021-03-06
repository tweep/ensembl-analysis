#!/usr/bin/env perl

# Copyright [1999-2014] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

package Merge::vega_check;

use strict;
use warnings;

use Exporter;

use vars qw(@ISA @EXPORT_OK);

@ISA = qw(Exporter);
@EXPORT_OK = qw(get_combos get_biotype_groups get_actions);

$| = 1;

my %allowed_combos = (
     'ensembl' => { # allowed gene-transcript biotypes combination before the merge
       '3prime_overlapping_ncrna'           => ['3prime_overlapping_ncrna',
                                                'retained_intron'],
       'antisense'                          => ['antisense','retained_intron'],
       'IG_gene'                            => ['IG_gene'],
       'IG_pseudogene'                      => ['IG_pseudogene'],
       'lincRNA'                            => ['lincRNA',
                                                'retained_intron'],
       'polymorphic_pseudogene'             => ['nonsense_mediated_decay',
                                                'non_stop_decay',
                                                'polymorphic_pseudogene',
                                                'protein_coding',
                                                'processed_transcript',
                                                'retained_intron'],
       'processed_pseudogene'               => ['processed_pseudogene'],
       'processed_transcript'               => ['3prime_overlapping_ncrna',
                                                'antisense',
                                                'lincRNA',
                                                'processed_transcript',
                                                'retained_intron',
                                                'sense_intronic',
                                                'sense_overlapping'],
       'protein_coding'                     => ['non_stop_decay',
                                                'nonsense_mediated_decay',
                                                'processed_transcript',
                                                'protein_coding',
                                                'retained_intron',
                                                'translated_unprocessed_pseudogene',
                                                'translated_processed_pseudogene'],
       'rRNA'                               => ['rRNA'],
       'sense_intronic'                     => ['retained_intron',
                                                'sense_intronic'],
       'sense_overlapping'                  => ['retained_intron',
                                                'sense_overlapping'],
       'TR_gene'                            => ['TR_gene'],
       'TR_pseudogene'                      => ['TR_pseudogene'],
       'translated_unprocessed_pseudogene'  => ['translated_unprocessed_pseudogene'],
       'translated_processed_pseudogene'    => ['translated_processed_pseudogene'],
       'unitary_pseudogene'                 => ['processed_transcript',
                                                'retained_intron',
                                                'unitary_pseudogene'],
       'unprocessed_pseudogene'             => ['unprocessed_pseudogene'],
       'transcribed_unprocessed_pseudogene' => ['transcribed_unprocessed_pseudogene',
                                                'processed_transcript',
                                                'retained_intron'],
       'transcribed_processed_pseudogene'   => ['transcribed_processed_pseudogene',
                                                'processed_transcript',
                                                'retained_intron']
     },

     'ensembl_extension' => { # additional allowed gene-transcript biotypes combination after the merge
       'antisense'                          => ['miRNA',
                                                'misc_RNA',
                                                'snoRNA'],
       'lincRNA'                            => ['miRNA',
                                                'misc_RNA',
                                                'rRNA',
                                                'snoRNA',
                                                'snRNA'],
       'miRNA'                              => ['miRNA'],
       'misc_RNA'                           => ['misc_RNA'],
       'non_coding'                         => ['miRNA'],
       'processed_transcript'               => ['miRNA',
                                                'misc_RNA',
                                                'snoRNA'],
       'rRNA'                               => ['rRNA'],
       'sense_intronic'                     => ['miRNA',
                                                'snoRNA',
                                                'snRNA'],
       'sense_overlapping'                  => ['miRNA'],
       'snoRNA'                             => ['snoRNA'],
       'snRNA'                              => ['snRNA'],
       'protein_coding'                     => ['IG_C_gene',
                                                'IG_V_gene',
                                                'IG_LV_gene'],
       'pseudogene'                         => ['disrupted_domain',
                                                'processed_pseudogene',
                                                'processed_transcript',
                                                'pseudogene',
                                                'retained_intron',
                                                'transcribed_processed_pseudogene',
                                                'transcribed_unprocessed_pseudogene',
                                                'translated_unprocessed_pseudogene',
                                                'translated_processed_pseudogene',
                                                'unitary_pseudogene',
                                                'unprocessed_pseudogene',
                                                # temporarily allowed
                                                'antisense',
                                                'lincRNA'],
       # temporarily allowed
       'processed_transcript'               => ['antisense',
                                                'lincRNA',
                                                'non_coding',
                                                'sense_intronic',
                                                'sense_overlapping'],
       'protein_coding'                     => ['antisense',
                                                'lincRNA',
                                                'sense_intronic'] },

     'havana' => { 
       protein_coding                       => ['protein_coding',
                                                'nonsense_mediated_decay',
                                                'non_stop_decay',
                                                'processed_transcript',
                                                'retained_intron',
                                                'artifact',
                                                'tec',
                                                'translated_processed_pseudogene',
                                                'translated_unprocessed_pseudogene'],
       polymorphic_pseudogene               => ['protein_coding',
                                                'nonsense_mediated_decay',
                                                'non_stop_decay',
                                                'processed_transcript',
                                                'retained_intron',
                                                'artifact',
                                                'tec',
                                                'polymorphic_pseudogene'],
       processed_transcript                 => ['processed_transcript',
                                                'retained_intron',
                                                'antisense',
                                                'artifact',
                                                'lincrna',
                                                'sense_intronic',
                                                'sense_overlapping',
                                                qq(3'_overlapping_ncrna),
                                                'tec'],
       'rRNA'                               => ['rRNA'],
       processed_pseudogene                 => ['processed_pseudogene'],
       unprocessed_pseudogene               => ['unprocessed_pseudogene'],
       transcribed_processed_pseudogene     => ['transcribed_processed_pseudogene',
                                                'processed_transcript',
                                                'retained_intron',
                                                'artifact',
                                                'tec'],
       transcribed_unprocessed_pseudogene   => ['transcribed_unprocessed_pseudogene',
                                                'processed_transcript',
                                                'retained_intron',
                                                'artifact',
                                                'tec'],
       unitary_pseudogene                   => ['unitary_pseudogene',
                                                'processed_transcript',
                                                'retained_intron',
                                                'artifact',
                                                'tec'],
       translated_processed_pseudogene      => ['translated_processed_pseudogene','protein_coding'],
       translated_unprocessed_pseudogene    => ['translated_unprocessed_pseudogene','protein_coding'],
       tec                                  => ['tec'],
       ig_pseudogene                        => ['ig_pseudogene'],
       novel_transcript                     => ['processed_transcript'],
       ig_gene                              => ['ig_gene',
                                                'artifact'],
       tr_gene                              => ['tr_gene'],
       tr_pseudogene                        => ['tr_pseudogene'],
       lincRNA                              => ['retained_intron',
                                                'lincrna',
                                                'artifact'],
       antisense                            => ['retained_intron',
                                                'antisense',
                                                'artifact'],
       sense_intronic                       => ['retained_intron',
                                                'sense_intronic',
                                                'artifact'],
       sense_overlapping                    => ['retained_intron',
                                                'sense_overlapping',
                                                'artifact'],
       qq(3'_overlapping_ncRNA)             => ['retained_intron',
                                                qq(3'_overlapping_ncrna),
                                                'artifact'],
     }
   );

my %biotype_groups = (
     'ensembl' => {
       'gene_coding'                        => ['IG_gene',
                                                'polymorphic_pseudogene',
                                                'protein_coding',
                                                'TR_gene'],
       'transcript_coding'                  => ['IG_gene',
                                                'IG_C_gene',
                                                'IG_V_gene',
                                                'IG_LV_gene',
                                                'non_stop_decay',
                                                'nonsense_mediated_decay',
                                                'polymorphic_pseudogene',
                                                'protein_coding',
                                                'TR_gene'],
       'gene_non_coding'                    => ['3prime_overlapping_ncrna',
                                                'antisense',
                                                'IG_pseudogene',
                                                'lincRNA',
                                                'miRNA',
                                                'misc_RNA',
                                                'processed_pseudogene',
                                                'processed_transcript',
                                                'pseudogene',
                                                'rRNA',
                                                'sense_intronic',
                                                'sense_overlapping',
                                                'snoRNA',
                                                'snRNA',
                                                'transcribed_unprocessed_pseudogene',
                                                'transcribed_processed_pseudogene',
                                                'translated_unprocessed_pseudogene',
                                                'translated_processed_pseudogene',
                                                'TR_pseudogene',
                                                'unitary_pseudogene',
                                                'unprocessed_pseudogene'],
       'transcript_non_coding'              => ['3prime_overlapping_ncrna',
                                                'antisense',
                                                'disrupted_domain',
                                                'IG_pseudogene',
                                                'lincRNA',
                                                'miRNA',
                                                'misc_RNA',
                                                'processed_transcript',
                                                'processed_pseudogene',
                                                'pseudogene',
                                                'rRNA',
                                                'retained_intron',
                                                'sense_intronic',
                                                'sense_overlapping',
                                                'snoRNA',
                                                'snRNA',
                                                'transcribed_unprocessed_pseudogene',
                                                'transcribed_processed_pseudogene',
                                                'translated_unprocessed_pseudogene',
                                                'translated_processed_pseudogene',
                                                'TR_pseudogene',
                                                'unitary_pseudogene',
                                                'unprocessed_pseudogene'] },

     'havana' => { }
);

# my %actions = (
#   'ensembl' => {
#     'gene' => {
#       'TEC' => {
#         sub {
#           die('die horribly if this biotype is seen');
#           }
#       } } }, {
#     'transcript' => {
#       'polymorphic_pseudogene' => {
#         sub {
#           print('change to protein coding if no stop codons');
#           }
#       } } },
#   'havana' => {
#     'gene' => {
#       'polymorphic' => sub {
#         print('ask again how loutre continues to contain these');
#         }
#     } } );

sub get_combos {
  my $combos_key = shift;
  return $allowed_combos{$combos_key};
}

sub get_biotype_groups {
  my $biotype_groups = shift;
  return $biotype_groups{$biotype_groups};
}

#sub get_actions {
#  my $actions_key = shift;
#  return $actions{$actions_key};
#}

1;
